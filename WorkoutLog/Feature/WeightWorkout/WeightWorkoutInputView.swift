//
//  WeightWorkoutInputView.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/8/25.
//

import UIKit
import RealmSwift
import SnapKit
import Then

final class WeightWorkoutInputView: UIControl {
    var onUpdate: ((Int, Int, Double) -> Void)?
    var onRemove: (() -> Void)?

    var selectedDate: Date = Date()

    var exerciseName: String? {
        return titleLabel.text
    }

    private var inputData: [WeightWorkout.SetInfo] = [WeightWorkout.SetInfo(weight: 0, reps: 0)]

    private var isUpdatingFromConfiguration: Bool = false

    let mainHeaderStack = UIStackView()

    private let closeButton = UIButton(type: .system).then {
        $0.setTitle("✕", for: .normal)
        $0.setTitleColor(.gray, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20)
    }

    private let tableView = UITableView()
    private var tableViewHeightConstraint: Constraint?

    private let titleLabel = UILabel().then {
        $0.text = nil
        $0.font = .boldSystemFont(ofSize: 18)
    }

    private let deleteButton = UIButton(type: .system).then {
        $0.setTitle("- 세트 삭제", for: .normal)
        $0.tintColor = .black
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.cornerRadius = 6
    }

    private let addButton = UIButton(type: .system).then {
        $0.setTitle("+ 세트 추가", for: .normal)
        $0.tintColor = .black
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.cornerRadius = 6
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    @objc private func headerTapped() {
        sendActions(for: .touchUpInside)
        print("header tapped")
    }

    private func setupUI() {
        mainHeaderStack.addArrangedSubview(titleLabel)
        mainHeaderStack.addArrangedSubview(closeButton)
        mainHeaderStack.axis = .horizontal
        mainHeaderStack.alignment = .center
        mainHeaderStack.distribution = .equalSpacing
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        mainHeaderStack.addGestureRecognizer(tapGesture)
        mainHeaderStack.isUserInteractionEnabled = true

        tableView.register(WorkoutCell.self, forCellReuseIdentifier: "WorkoutCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints {
            self.tableViewHeightConstraint = $0.height.equalTo(60).priority(.low).constraint
        }

        let buttonStack = UIStackView(arrangedSubviews: [deleteButton, addButton]).then {
            $0.axis = .horizontal
            $0.spacing = 16
            $0.distribution = .fillEqually
        }

        addButton.addTarget(self, action: #selector(addSet), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteSet), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(removeSelf), for: .touchUpInside)

        let mainStack = UIStackView(arrangedSubviews: [mainHeaderStack, tableView, buttonStack]).then {
            $0.axis = .vertical
            $0.spacing = 12
        }

        mainStack.setContentHuggingPriority(.required, for: .vertical)
        addSubview(mainStack)

        mainStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
    }

    private func updateTableViewHeight() {
        DispatchQueue.main.async {
            self.tableView.layoutIfNeeded()
            let contentHeight = self.tableView.contentSize.height
            self.tableViewHeightConstraint?.update(offset: contentHeight)
            self.superview?.layoutIfNeeded()
        }
    }

    @objc private func addSet() {
        inputData.append(WeightWorkout.SetInfo(weight: 0, reps: 0))
        tableView.reloadData()
        updateTableViewHeight()
        saveWorkoutToRealm(date: selectedDate)
    }

    @objc private func deleteSet() {
        guard inputData.count > 1 else { return }
        inputData.removeLast()
        tableView.reloadData()
        updateTableViewHeight()
        saveWorkoutToRealm(date: selectedDate)
    }

    @objc private func removeSelf() {
        guard let viewController = self.findViewController() else {
            removeFromSuperview()
            return
        }

        let alert = UIAlertController(title: "삭제 확인", message: "정말로 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            self.deleteWorkoutFromRealm(date: self.selectedDate)
            self.removeFromSuperview()
            self.onRemove?()
        }))
        viewController.present(alert, animated: true, completion: nil)
    }

    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController {
                return vc
            }
            responder = r.next
        }
        return nil
    }

    private func deleteWorkoutFromRealm(date: Date) {
        guard let fullTitle = titleLabel.text else { return }
        let exerciseName = fullTitle.contains("|") ? fullTitle.components(separatedBy: "|").last?.trimmingCharacters(in: .whitespaces) : fullTitle
        guard let name = exerciseName, !name.isEmpty else { return }

        let realm = try! Realm()
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let objectsToDelete = realm.objects(WorkoutSetObject.self)
            .filter("exerciseName == %@ AND date >= %@ AND date < %@", name, startOfDay, endOfDay)

        try? realm.write {
            realm.delete(objectsToDelete)
        }
    }

    @objc private func textFieldDidChange() {
        guard !isUpdatingFromConfiguration else { return }
        saveWorkoutToRealm(date: selectedDate)
    }

    func saveWorkoutToRealm(date: Date) {
        guard let fullTitle = titleLabel.text else { return }
        let exerciseName = fullTitle.contains("|") ? fullTitle.components(separatedBy: "|").last?.trimmingCharacters(in: .whitespaces) : fullTitle
        guard let name = exerciseName, !name.isEmpty else { return }

        let realm = try! Realm()
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let existingObjects = realm.objects(WorkoutSetObject.self)
            .filter("exerciseName == %@ AND date >= %@ AND date < %@", name, startOfDay, endOfDay)

        try? realm.write {
            realm.delete(existingObjects)

            for (index, set) in inputData.enumerated() {
                let workout = WorkoutSetObject()
                workout.exerciseName = name
                workout.weight = set.weight
                workout.repetitions = set.reps
                workout.sets = index + 1
                workout.date = startOfDay
                realm.add(workout)
            }
        }
    }

    func configure(with workout: WeightWorkout, date: Date) {
        isUpdatingFromConfiguration = true
        self.selectedDate = date
        let realm = try! Realm()
        let category = realm.objects(ExerciseObject.self)
            .filter("name == %@", workout.exerciseName)
            .first?.category ?? ""
        titleLabel.text = "\(category) | \(workout.exerciseName)"

        let objects = realm.objects(WorkoutSetObject.self)
            .filter("exerciseName == %@ AND date >= %@ AND date < %@", workout.exerciseName, date, Calendar.current.date(byAdding: .day, value: 1, to: date)!)
            .sorted(byKeyPath: "sets", ascending: true)
        self.inputData = objects.map { WeightWorkout.SetInfo(weight: $0.weight, reps: $0.repetitions) }
        tableView.reloadData()
        layoutIfNeeded()
        updateTableViewHeight()

        isUpdatingFromConfiguration = false
    }

    func configureTitle(_ title: String) {
        if !title.contains("|") {
            titleLabel.text = title
        }
    }
    
    // 터치 애니메이션 추가
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animate(scale: 0.95)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animate(scale: 1.0)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animate(scale: 1.0)
    }

    private func animate(scale: CGFloat) {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: nil)
    }
}

extension WeightWorkoutInputView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inputData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath) as? WorkoutCell else {
            return UITableViewCell()
        }
        let setInfo = inputData[indexPath.row]
        cell.configure(set: indexPath.row + 1, weight: setInfo.weight, reps: setInfo.reps)
        cell.onUpdate = { [weak self] weight, reps in
            self?.inputData[indexPath.row] = WeightWorkout.SetInfo(weight: weight, reps: reps)
            self?.saveWorkoutToRealm(date: self?.selectedDate ?? Date())
        }
        return cell
    }
}
