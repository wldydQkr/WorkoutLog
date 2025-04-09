//
//  ExerciseSelectionViewController.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/9/25.
//

import UIKit

class ExerciseSelectionViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var categories: [ExerciseCategory] = [
        ExerciseCategory(name: "가슴", exercises: ["덤벨 플라이", "벤치 프레스", "체스트 프레스"]),
        ExerciseCategory(name: "등", exercises: ["덤벨 로우", "데드리프트", "랫 풀다운"]),
        ExerciseCategory(name: "어깨", exercises: [])
    ]
    
    private var selectedExercises: Set<String> = []
    var onExercisesSelected: (([String]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "운동 선택"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneTapped)),
            UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(editTapped))
        ]

        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        view.addSubview(tableView)
        tableView.frame = view.bounds
    }

    @objc private func doneTapped() {
        let selected = Array(selectedExercises)
        onExercisesSelected?(selected)
        
        if let navigationController = self.navigationController,
           let workoutVC = navigationController.viewControllers.first(where: { $0 is WeightWorkoutViewController }) as? WeightWorkoutViewController {
            workoutVC.addInputViews(for: selected)
        }
        
        navigationController?.popViewController(animated: true)
    }

    @objc private func editTapped() {
        // 섹션/운동 추가 모달 띄우기 (추후 구현)
    }
    
    
    @objc private func completeButtonTapped() {
        // 선택한 운동들 전달
    }
}

extension ExerciseSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section].name
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
        selectedExercises.insert(exercise)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let exercise = categories[indexPath.section].exercises[indexPath.row]
        selectedExercises.remove(exercise)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
