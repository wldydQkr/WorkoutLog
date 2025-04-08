//
//  WeightWorkoutViewController.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/8/25.
//

import UIKit
import SnapKit
import Then
import Combine

// MARK: - ViewController
class WeightWorkoutViewController: UIViewController {
    private let viewModel = WeightWorkoutViewModel()
    private let contentStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel().then {
            $0.text = viewModel.currentDateString
            $0.font = .boldSystemFont(ofSize: 24)
        }

        let calendarView = UIView().then {
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = 12
        }

        let scrollView = UIScrollView()
        
        scrollView.addSubview(contentStack)
        view.addSubview(titleLabel)
        view.addSubview(calendarView)
        view.addSubview(scrollView)

        let addWorkoutButton = UIButton(type: .system).then {
            $0.setTitle("+ 운동 추가", for: .normal)
            $0.titleLabel?.font = .boldSystemFont(ofSize: 18)
        }

        view.addSubview(addWorkoutButton)

        addWorkoutButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            $0.height.equalTo(44)
            $0.width.equalTo(120)
        }

        addWorkoutButton.addTarget(self, action: #selector(addWorkoutTapped), for: .touchUpInside)

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }

        calendarView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(300)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
    }

    @objc private func addWorkoutTapped() {
        let workoutView = WeightWorkoutInputView()
        workoutView.onUpdate = { [weak self] (sets: Int, repetitions: Int, weight: Double) in
            guard let self = self else { return }
            let tempID = UUID()
            self.viewModel.updateWorkout(id: tempID, sets: sets, repetitions: repetitions, weight: weight)
        }
        contentStack.addArrangedSubview(workoutView)
    }
}

// ViewModel
extension WeightWorkoutViewModel {
    var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: Date())
    }
}
