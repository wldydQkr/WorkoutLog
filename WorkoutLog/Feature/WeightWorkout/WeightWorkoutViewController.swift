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
class WeightWorkoutViewController: UIViewController, UIScrollViewDelegate {
    private let viewModel = WeightWorkoutViewModel()
    private var lastContentOffset: CGFloat = 0
    private let emptyLabel = UILabel().then {
        $0.text = "운동 기록을 추가해보세요!"
        $0.font = .systemFont(ofSize: 18, weight: .regular)
        $0.textColor = .gray
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.isHidden = true
    }
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
    
    private let scrollView = UIScrollView()
    private let addWorkoutButton = UIButton(type: .system).then {
        $0.setTitle("+ 운동 추가", for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 18)
        $0.tintColor = .white
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 22
    }
    
    private let buttonStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.distribution = .equalSpacing
    }
    
    private var selectedDate: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        setTransparentStatusBar()
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
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
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
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(calendarView.snp.width).multipliedBy(1.0)
        }

        buttonStack.addArrangedSubview(hideDateButton)
        buttonStack.addArrangedSubview(addWorkoutButton)
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

        scrollView.delegate = self
    }

    func addInputViews(for exercises: [String]) {
        // 운동 항목이 없으면 아무 작업도 하지 않음
        guard !exercises.isEmpty else { return }

        // 날짜 선택기 이후의 모든 운동 입력 뷰 제거
        let preservedCount = 2
        let toRemove = contentStack.arrangedSubviews.dropFirst(preservedCount)
        toRemove.forEach { view in
            contentStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        // 중복 제거 (입력 순서 유지)
        var seen = Set<String>()
        let uniqueExercises = exercises.filter { seen.insert($0).inserted }

        // 이미 저장된 운동이 있는지 확인 (중복 추가 방지)
        let realm = try! Realm()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let existingWorkouts = realm.objects(WorkoutSetObject.self)
            .filter("date >= %@ AND date < %@", startOfDay, endOfDay)

        let existingExerciseNames = Set(existingWorkouts.map { $0.exerciseName })

        for exercise in uniqueExercises {
            // 동일 날짜에 같은 운동이 이미 존재하면 추가하지 않음
            if contentStack.arrangedSubviews.contains(where: {
                guard let inputView = $0 as? WeightWorkoutInputView else { return false }
                return inputView.exerciseName == exercise
            }) {
                continue
            }

            let inputView = WeightWorkoutInputView()
            inputView.configureTitle(exercise)
            inputView.selectedDate = selectedDate
            contentStack.addArrangedSubview(inputView)
        }
        
        calendarView.reloadDecorations(forDateComponents: [Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)], animated: true)
    }

    @objc private func addWorkoutTapped() {
        let selectionVC = ExerciseSelectionViewController(selectedDate: selectedDate)
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

        // Retrieve workout groups from view model
        let grouped = viewModel.workoutGroups(for: date)

        // If no workouts exist, remove all WeightWorkoutInputView and return
        if grouped.isEmpty {
            contentStack.arrangedSubviews.forEach { view in
                if view is WeightWorkoutInputView {
                    contentStack.removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
            }
            emptyLabel.isHidden = false
            return
        } else {
            emptyLabel.isHidden = true
        }

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

        emptyLabel.isHidden = true
        for (exerciseName, sets) in grouped {
            let workoutView = WeightWorkoutInputView()
            let workout = WeightWorkout(exerciseName: exerciseName, sets: sets.map {
                WeightWorkout.SetInfo(weight: $0.weight, reps: $0.repetitions)
            }, date: date)
            workoutView.configure(with: workout, date: date)
            contentStack.addArrangedSubview(workoutView)
        }
        
        calendarView.reloadDecorations(forDateComponents: [Calendar.current.dateComponents([.year, .month, .day], from: date)], animated: true)
    }

    @objc private func toggleCalendarView() {
        calendarView.isHidden.toggle()
        let imageName = calendarView.isHidden ? "chevron.up" : "chevron.down"
        hideDateButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height

        if offset <= 0 {
            // 최상단 도달 → 버튼 무조건 보이기
            UIView.animate(withDuration: 0.3) {
                self.buttonStack.alpha = 1
            }
        } else if offset >= maxOffset {
            // 최하단 도달 → 버튼 무조건 숨기기
            UIView.animate(withDuration: 0.3) {
                self.buttonStack.alpha = 0
            }
        } else if offset > lastContentOffset {
            // 아래로 스크롤 중 (탭바 방향) → 버튼 숨김
            UIView.animate(withDuration: 0.3) {
                self.buttonStack.alpha = 0
            }
        } else if offset < lastContentOffset {
            // 위로 스크롤 중 (상태바 방향) → 버튼 보이기
            UIView.animate(withDuration: 0.3) {
                self.buttonStack.alpha = 1
            }
        }

        lastContentOffset = offset
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
