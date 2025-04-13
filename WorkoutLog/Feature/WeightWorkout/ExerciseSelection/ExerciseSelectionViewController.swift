//
//  ExerciseSelectionViewController.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/9/25.
//

import UIKit
import SnapKit
import Then
import RealmSwift

class ExerciseObject: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String
    @Persisted var category: String
}

class ExerciseSelectionViewController: UIViewController {

    private let realm = try! Realm()
    private var categories: [ExerciseCategory] = []
    private let tableView = UITableView()
    private var isEditingSection: Bool = false
    private var isDeleteMode: Bool = false

    private func ensureInitialExercises() {
        let existing = realm.objects(ExerciseObject.self)
        let defaultData: [ExerciseCategory] = [
            ExerciseCategory(name: "가슴", exercises: ["덤벨 플라이", "벤치 프레스", "체스트 프레스"]),
            ExerciseCategory(name: "등", exercises: ["덤벨 로우", "데드리프트", "랫 풀다운"]),
            ExerciseCategory(name: "어깨", exercises: ["오버헤드 프레스", "덤벨 프레스", "머신 프레스"]),
            ExerciseCategory(name: "팔", exercises: ["바벨 컬", "프리쳐 컬", "오버헤드 익스텐션", "라잉 트라이셉스 익스텐션"]),
            ExerciseCategory(name: "복근", exercises: ["케이블 크런치", "행잉 오버 레그 레이즈", "AB 슬라이드"]),
            ExerciseCategory(name: "하체", exercises: ["스쿼트", "브이 스쿼트", "불가리안 스플릿 스쿼트", "레그 익스텐션", "레그 컬"])
        ]
        if existing.isEmpty {
            try? realm.write {
                for category in defaultData {
                    for name in category.exercises {
                        let obj = ExerciseObject()
                        obj.name = name
                        obj.category = category.name
                        realm.add(obj)
                    }
                }
            }
        }
    }
    
    private var selectedExercises: Set<String> = []
    var onExercisesSelected: (([String]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        ensureInitialExercises()
        loadExercisesFromRealm()
        setupUI()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }

    private func loadExercisesFromRealm() {
        let all = realm.objects(ExerciseObject.self)
        let grouped = Dictionary(grouping: all, by: { $0.category })
        categories = grouped.map { ExerciseCategory(name: $0.key, exercises: $0.value.map { $0.name }) }
            .sorted(by: { $0.name < $1.name })
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        let headerView = UIView().then {
            $0.backgroundColor = .white
        }
        view.addSubview(headerView)

        let backButton = UIButton(type: .system).then {
            $0.setTitle("〈", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
            $0.tintColor = .black
            $0.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        }

        let titleLabel = UILabel().then {
            $0.text = "운동 선택"
            $0.font = .boldSystemFont(ofSize: 15)
            $0.textAlignment = .center
        }

        let editButton = UIButton(type: .system).then {
            $0.setTitle("편집", for: .normal)
            $0.tintColor = .black
            $0.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        }

        let doneButton = UIButton(type: .system).then {
            $0.setTitle("완료", for: .normal)
            $0.tintColor = .black
            $0.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        }

        let rightStack = UIStackView(arrangedSubviews: [editButton, doneButton]).then {
            $0.axis = .horizontal
            $0.spacing = 8
        }

        let headerStack = UIStackView(arrangedSubviews: [backButton, titleLabel, rightStack]).then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }

        headerView.addSubview(headerStack)

        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }

        headerStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tintColor = .black

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    @objc private func doneTapped() {
        let selected = Array(selectedExercises)
        onExercisesSelected?(selected)
        navigationController?.popViewController(animated: true)
    }

    @objc private func editTapped() {
        isEditingSection.toggle()
        isDeleteMode = false
        tableView.reloadData()
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func completeButtonTapped() {
        // 선택한 운동들 전달
    }
    
    @objc private func addExerciseTapped(_ sender: UIButton) {
        let category = categories[sender.tag].name

        let alert = UIAlertController(title: "\(category) 운동 추가", message: "운동 이름을 입력하세요", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "운동 이름" }

        let addAction = UIAlertAction(title: "추가", style: .default) { _ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }

            do {
                let newExercise = ExerciseObject()
                newExercise.name = name
                newExercise.category = category

                try self.realm.write {
                    self.realm.add(newExercise)
                }
                print("✅ 운동 저장 성공: \(name)")
            } catch {
                print("❌ Realm 저장 실패: \(error.localizedDescription)")
            }

            self.loadExercisesFromRealm()
            self.tableView.reloadData()
        }

        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))

        present(alert, animated: true)
    }

    @objc private func editSectionTapped(_ sender: UIButton) {
        let category = categories[sender.tag].name
        // implement edit logic
    }

    @objc private func deleteSectionTapped(_ sender: UIButton) {
        isDeleteMode.toggle()
        tableView.setEditing(isDeleteMode, animated: true)
    }
}

extension ExerciseSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories[section].exercises.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exercise = categories[indexPath.section].exercises[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = exercise
        cell.accessoryType = selectedExercises.contains(exercise) ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let exercise = categories[indexPath.section].exercises[indexPath.row]
        if selectedExercises.contains(exercise) {
            selectedExercises.remove(exercise)
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            selectedExercises.insert(exercise)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let titleLabel = UILabel().then {
            $0.text = categories[section].name
            $0.font = .boldSystemFont(ofSize: 16)
        }
        let addButton = UIButton(type: .system).then {
            $0.setTitle("추가", for: .normal)
            $0.addTarget(self, action: #selector(addExerciseTapped(_:)), for: .touchUpInside)
            $0.tag = section
        }
        let editButton = UIButton(type: .system).then {
            $0.setTitle("수정", for: .normal)
            $0.addTarget(self, action: #selector(editSectionTapped(_:)), for: .touchUpInside)
            $0.tag = section
        }
        let deleteButton = UIButton(type: .system).then {
            $0.setTitle("삭제", for: .normal)
            $0.addTarget(self, action: #selector(deleteSectionTapped(_:)), for: .touchUpInside)
            $0.tag = section
        }

        let buttonStack = UIStackView()
        if isEditingSection {
            buttonStack.addArrangedSubview(addButton)
            buttonStack.addArrangedSubview(editButton)
            buttonStack.addArrangedSubview(deleteButton)
        }
        buttonStack.axis = .horizontal
        buttonStack.spacing = 8

        let hStack = UIStackView(arrangedSubviews: [titleLabel, buttonStack])
        hStack.axis = .horizontal
        hStack.distribution = .equalSpacing
        hStack.alignment = .center

        header.addSubview(hStack)
        hStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(16) }
        return header
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isDeleteMode
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let exerciseName = categories[indexPath.section].exercises[indexPath.row]
        let categoryName = categories[indexPath.section].name

        let alert = UIAlertController(
            title: "운동 삭제",
            message: "\(exerciseName)를 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            if let objectToDelete = self.realm.objects(ExerciseObject.self)
                .filter("name == %@ AND category == %@", exerciseName, categoryName)
                .first {
                try? self.realm.write {
                    self.realm.delete(objectToDelete)
                }
                self.loadExercisesFromRealm()
                self.tableView.reloadData()
            }
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

#if DEBUG
import SwiftUI

struct ExerciseSelectionViewController_Preview: PreviewProvider {
    static var previews: some View {
        ExerciseSelectionViewControllerPreview()
            .edgesIgnoringSafeArea(.all)
    }

    struct ExerciseSelectionViewControllerPreview: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UIViewController {
            return ExerciseSelectionViewController()
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            // Nothing to update
        }
    }
}
#endif
