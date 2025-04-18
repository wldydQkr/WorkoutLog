//
//  WeightWorkoutViewController.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/8/25.
//

import UIKit
import SnapKit
import Then
import RealmSwift

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
    private let calendarView = UICalendarView().then {
        $0.tintColor = .black
        $0.locale = Locale(identifier: "ko_KR")
        $0.calendar = Calendar(identifier: .gregorian)
        $0.fontDesign = .monospaced
        $0.availableDateRange = DateInterval(start: .distantPast, end: .distantFuture)
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.preservesSuperviewLayoutMargins = false
    }
    
    private let emptyLabel = UILabel().then {
        $0.text = "운동을 추가 해보세요!"
        $0.textAlignment = .center
        $0.textColor = .gray
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.isHidden = true
    }
    
    private var selectedDate: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        setupUI()
        setupCalendar()
        updateSelectedDate(selectedDate)
    }
    
    private func setupCalendar() {
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = dateSelection
        
        // 오늘 날짜 선택 - Date를 DateComponents로 변환
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        (calendarView.selectionBehavior as? UICalendarSelectionSingleDate)?.setSelected(dateComponents, animated: false)
        
        calendarView.delegate = self
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

        hideDateButton.addTarget(self, action: #selector(toggleCalendarView), for: .touchUpInside)

        let titleStack = UIStackView(arrangedSubviews: [titleLabel]).then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }
        contentStack.addArrangedSubview(calendarView)
        contentStack.addArrangedSubview(emptyLabel)
        
        titleLabel.text = viewModel.currentDateString

        calendarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(calendarView.snp.width).multipliedBy(1.0)
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
        guard !exercises.isEmpty else { return }

        // 현재 뷰에 있는 운동 이름 추출
        let existingViews = contentStack.arrangedSubviews.compactMap {
            ($0 as? WeightWorkoutInputView)?.exerciseName
        }

        // Realm에서 현재 날짜의 운동 이름 확인
        let realm = try! Realm()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let existingWorkouts = realm.objects(WorkoutSetObject.self)
            .filter("date >= %@ AND date < %@", startOfDay, endOfDay)
        let existingExerciseNames = Set(existingWorkouts.map { $0.exerciseName })

        // 중복 제거 후 새로운 운동만 추가
        let uniqueExercises = exercises
            .filter { !existingExerciseNames.contains($0) && !existingViews.contains($0) }

        let sortedExercises = uniqueExercises.sorted {
            let category0 = realm.objects(ExerciseObject.self).filter("name == %@", $0).first?.category ?? ""
            let category1 = realm.objects(ExerciseObject.self).filter("name == %@", $1).first?.category ?? ""
            return category0 < category1
        }

        for exercise in sortedExercises {
            let inputView = WeightWorkoutInputView()
            inputView.configureTitle(exercise)
            inputView.selectedDate = selectedDate
            contentStack.addArrangedSubview(inputView)
        }

        emptyLabel.isHidden = true

        calendarView.reloadDecorations(
            forDateComponents: [Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)],
            animated: true
        )
    }

    @objc private func addWorkoutTapped() {
        let selectionVC = ExerciseSelectionViewController()
        selectionVC.selectedDate = self.selectedDate
        selectionVC.onExercisesSelected = { [weak self] selectedExercises in
            self?.addInputViews(for: selectedExercises)
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(selectionVC, animated: true)
    }
    
    private func updateSelectedDate(_ date: Date) {
        self.selectedDate = date
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        titleLabel.text = formatter.string(from: date)

        // 날짜 변경 시 기존 운동 뷰 제거 (상단 뷰 제외)
        let preservedViews = contentStack.arrangedSubviews.prefix(2)
        contentStack.arrangedSubviews.dropFirst(2).forEach { view in
            contentStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        // Realm에서 선택된 날짜의 운동 데이터 조회
        let realm = try! Realm()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let results = realm.objects(WorkoutSetObject.self)
            .filter("date >= %@ AND date < %@", startOfDay, endOfDay)
            .sorted(byKeyPath: "sets")

        // Realm에 데이터가 없으면 모든 InputView 제거 후 리턴
        if results.isEmpty {
            emptyLabel.isHidden = false
            contentStack.arrangedSubviews.forEach { view in
                if view is WeightWorkoutInputView {
                    contentStack.removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
            }
            return
        }

        guard !results.isEmpty else { return }

        let grouped = Dictionary(grouping: results, by: { $0.exerciseName })

        // 현재 날짜의 운동 이름들만 유지하고 나머지 InputView는 제거
        let validExerciseNames = Set(grouped.keys)
        contentStack.arrangedSubviews.forEach { view in
            if let inputView = view as? WeightWorkoutInputView,
               let exerciseName = inputView.exerciseName,
               !validExerciseNames.contains(exerciseName) {
                contentStack.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }

        for (exerciseName, sets) in grouped {
            let workoutView = WeightWorkoutInputView()
            let workout = WeightWorkout(exerciseName: exerciseName, sets: sets.map {
                WeightWorkout.SetInfo(weight: $0.weight, reps: $0.repetitions)
            }, date: date)
            workoutView.configure(with: workout, date: date)
            contentStack.addArrangedSubview(workoutView)
        }
        
        emptyLabel.isHidden = true
        
        calendarView.reloadDecorations(forDateComponents: [Calendar.current.dateComponents([.year, .month, .day], from: date)], animated: true)
    }

    @objc private func toggleCalendarView() {
        calendarView.isHidden.toggle()
        let imageName = calendarView.isHidden ? "chevron.up" : "chevron.down"
        hideDateButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}

// MARK: - UICalendarSelectionSingleDateDelegate
extension WeightWorkoutViewController: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents,
              let date = Calendar.current.date(from: dateComponents) else { return }
        
        updateSelectedDate(date)
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
        // 모든 날짜 선택 가능 (필요하면 제한 추가)
        return true
    }
}

// MARK: - UICalendarViewDelegate
extension WeightWorkoutViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        guard let date = Calendar.current.date(from: dateComponents) else { return nil }

        let realm = try! Realm()
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let results = realm.objects(WorkoutSetObject.self)
            .filter("date >= %@ AND date < %@", startOfDay, endOfDay)

        return results.isEmpty ? nil : .default(color: .black)
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
            // 업데이트 로직 없음
        }
    }
}
#endif
