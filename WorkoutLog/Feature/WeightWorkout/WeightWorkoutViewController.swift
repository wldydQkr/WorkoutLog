//
//  WeightWorkoutViewController.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/8/25.
//

import UIKit
import SnapKit
import Then
//import Combine

// MARK: - ViewController
class WeightWorkoutViewController: UIViewController {
    private let viewModel = WeightWorkoutViewModel()
    private let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 24)
    }
    private let hideDateButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = .black
    }
    private let contentStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
    }
    private let datePicker = UIDatePicker().then {
        $0.preferredDatePickerStyle = .inline
        $0.tintColor = .black
        $0.datePickerMode = .date
        $0.locale = Locale(identifier: "ko_KR")
        $0.calendar = Calendar(identifier: .gregorian)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        setupUI()
    }

    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
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

        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        hideDateButton.addTarget(self, action: #selector(toggleDatePicker), for: .touchUpInside)

        let titleStack = UIStackView(arrangedSubviews: [titleLabel]).then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }
        contentStack.addArrangedSubview(datePicker)
        
        titleLabel.text = viewModel.currentDateString

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

        let buttonStack = UIStackView(arrangedSubviews: [hideDateButton, addWorkoutButton]).then {
            $0.axis = .horizontal
            $0.spacing = 16
            $0.distribution = .equalSpacing
        }
        view.addSubview(buttonStack)
        buttonStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(44)
        }

        addWorkoutButton.snp.makeConstraints {
            $0.width.equalTo(120)
        }

        hideDateButton.snp.makeConstraints {
            $0.width.equalTo(44)
        }
        
        addWorkoutButton.addTarget(self, action: #selector(addWorkoutTapped), for: .touchUpInside)
        
        hideDateButton.layer.cornerRadius = 22
        hideDateButton.backgroundColor = .black
    }

    func addInputViews(for exercises: [String]) {
        // Remove all workout views after the date picker
        let preservedCount = 2
        let toRemove = contentStack.arrangedSubviews.dropFirst(preservedCount)
        toRemove.forEach { view in
            contentStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        // Remove duplicates while preserving order
        var seen = Set<String>()
        let uniqueExercises = exercises.filter { seen.insert($0).inserted }

        // Add new input views
        for exercise in uniqueExercises {
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

    @objc private func toggleDatePicker() {
        datePicker.isHidden.toggle()
        let imageName = datePicker.isHidden ? "chevron.up" : "chevron.down"
        hideDateButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}

#if DEBUG
import SwiftUI

struct WeightWorkoutViewController_Preview: PreviewProvider {
    static var previews: some View {
        WeightWorkoutViewControllerPreview()
            .edgesIgnoringSafeArea(.all)
    }

    struct WeightWorkoutViewControllerPreview: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UIViewController {
            return WeightWorkoutViewController()
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            // No update logic
        }
    }
}
#endif
