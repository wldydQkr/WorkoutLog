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
    private let titleLabel = UILabel()
    private let contentStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        setupUI()
    }

    private func setupUI() {
        let scrollView = UIScrollView()
        view.addSubview(scrollView)

        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        scrollView.addSubview(contentStack)
        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }

        titleLabel.text = viewModel.currentDateString
        titleLabel.font = .boldSystemFont(ofSize: 24)

        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(datePicker)

        titleLabel.snp.makeConstraints {
            $0.height.equalTo(40)
        }

        datePicker.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        let addWorkoutButton = UIButton(type: .system).then {
            $0.setTitle("+ 운동 추가", for: .normal)
            $0.titleLabel?.font = .boldSystemFont(ofSize: 18)
            $0.tintColor = .white
            $0.backgroundColor = .black
            $0.layer.cornerRadius = 22
        }

        view.addSubview(addWorkoutButton)
        addWorkoutButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            $0.height.equalTo(44)
            $0.width.equalTo(120)
        }

        addWorkoutButton.addTarget(self, action: #selector(addWorkoutTapped), for: .touchUpInside)
    }

    func addInputViews(for exercises: [String]) {
        // Remove old workout views
        let preservedViews = contentStack.arrangedSubviews.prefix(2)
        contentStack.arrangedSubviews.dropFirst(2).forEach { view in
            contentStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        // Add new input views
        for exercise in exercises {
            let inputView = WeightWorkoutInputView()
            inputView.configureTitle(exercise)
            contentStack.addArrangedSubview(inputView)
        }
    }

    @objc private func addWorkoutTapped() {
        let selectionVC = ExerciseSelectionViewController()
        selectionVC.onExercisesSelected = { [weak self] selectedExercises in
            self?.addInputViews(for: selectedExercises)
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(selectionVC, animated: true)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let date = sender.date

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        titleLabel.text = formatter.string(from: date)

        let preservedViews = contentStack.arrangedSubviews.prefix(2)
        contentStack.arrangedSubviews.dropFirst(2).forEach { view in
            contentStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let calendar = Calendar.current
        let workoutsForDate = viewModel.workouts.filter {
            calendar.isDate($0.date, inSameDayAs: date)
        }

        for workout in workoutsForDate {
            let workoutView = WeightWorkoutInputView()
            workoutView.configure(with: workout)
            contentStack.addArrangedSubview(workoutView)
        }
    }
}
