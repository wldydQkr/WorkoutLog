//
//  ExerciseSelectionViewController.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/9/25.
//

import UIKit
import SnapKit
import Then

class ExerciseSelectionViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private var categories: [ExerciseCategory] = [
        ExerciseCategory(name: "가슴", exercises: ["덤벨 플라이", "벤치 프레스", "체스트 프레스"]),
        ExerciseCategory(name: "등", exercises: ["덤벨 로우", "데드리프트", "랫 풀다운"]),
        ExerciseCategory(name: "어깨", exercises: ["오버헤드 프레스", "덤벨 프레스", "머신 프레스"]),
        ExerciseCategory(name: "팔", exercises: ["바벨 컬", "프리쳐 컬", "오버헤드 익스텐션", "라잉 트라이셉스 익스텐션"]),
        ExerciseCategory(name: "복근", exercises: ["케이블 크런치", "행잉 오버 레그 레이즈", "AB 슬라이드"]),
        ExerciseCategory(name: "하체", exercises: ["스쿼트", "브이 스쿼트", "불가리안 스플릿 스쿼트", "레그 익스텐션", "레그 컬"])
    ]
    
    private var selectedExercises: Set<String> = []
    var onExercisesSelected: (([String]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        setupUI()
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
        // 섹션/운동 추가 모달 띄우기 (추후 구현)
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
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
