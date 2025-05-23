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
        // If you want to respect layout margins in the label, uncomment below:
        // $0.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        // $0.preservesSuperviewLayoutMargins = true
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
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
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
    
    private var selectedDate: Date = Calendar.current.startOfDay(for: Date())

    override func viewDidLoad() {
        super.viewDidLoad()
        setTransparentStatusBar()
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        setupUI()
        setupCalendar()
        updateSelectedDate(selectedDate)
        // 키보드 알림 옵저버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // 화면 터치 시 키보드를 내리기 위한 제스처
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupCalendar() {
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = dateSelection
        
        // 오늘 날짜를 선택 - Date를 DateComponents로 변환
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

        contentStack.addArrangedSubview(calendarView)
        contentStack.addArrangedSubview(emptyLabel)
        contentStack.setCustomSpacing(-20, after: calendarView)
        
        titleLabel.text = viewModel.currentDateString

        calendarView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(UIScreen.main.bounds.width * 1.15)
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
            // 동일한 날짜에 같은 운동이 존재하면 추가하지 않음
            if contentStack.arrangedSubviews.contains(where: {
                guard let inputView = $0 as? WeightWorkoutInputView else { return false }
                return inputView.exerciseName == exercise
            }) {
                continue
            }

            let workout = WeightWorkout(
                exerciseName: exercise,
                sets: [WeightWorkout.SetInfo(weight: 0, reps: 0)],
                date: selectedDate
            )
            // addInputViews 메서드 수정
            let inputView = WeightWorkoutInputView()
            inputView.configure(with: workout, date: selectedDate)
            // 제스처 등록 부분 제거, 대신 UIControl 이벤트 연결
            inputView.addTarget(self, action: #selector(handleInputViewTapped(_:)), for: .touchUpInside)
            inputView.isUserInteractionEnabled = true
            contentStack.addArrangedSubview(inputView)
//            emptyLabel을 숨김
        }
        
        calendarView.reloadDecorations(forDateComponents: [Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)], animated: true)
        
        let hasWorkoutViews = contentStack.arrangedSubviews.contains(where: { $0 is WeightWorkoutInputView })
        emptyLabel.isHidden = hasWorkoutViews

        // 운동 입력 뷰 추가 후 스크롤을 맨 아래로 이동 (애니메이션 없음)
        DispatchQueue.main.async {
            let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height + self.scrollView.contentInset.bottom)
            self.scrollView.setContentOffset(bottomOffset, animated: false)
        }
    }

    // 기존 제스처 핸들러는 더 이상 사용하지 않음
    @objc private func handleInputViewTapped(_ sender: UIControl) {
        guard let inputView = sender as? WeightWorkoutInputView else {
            print("⚠️ sender is not WeightWorkoutInputView")
            return
        }
        guard let exerciseName = inputView.exerciseName else {
            print("⚠️ exerciseName is nil")
            return
        }
        print("✅ Navigating to chart for exercise:", exerciseName)
        let chartVC = WorkoutChartDetailViewController(exerciseName: exerciseName)
        navigationController?.pushViewController(chartVC, animated: true)
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

        // 날짜가 변경되면 기존 운동 뷰 제거 (상단 뷰 제외)
        let preservedViews = contentStack.arrangedSubviews.prefix(2)
        contentStack.arrangedSubviews.dropFirst(2).forEach { view in
            contentStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        // 뷰모델에서 운동 그룹 가져오기
        let grouped = viewModel.workoutGroups(for: date)

        // 운동이 없으면 모든 WeightWorkoutInputView를 제거하고 리턴
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

        // 현재 날짜의 운동 이름만 유지하고 나머지 InputView 제거
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
        let sortedGrouped = grouped.sorted {
            guard let lhsDate = $0.value.sorted(by: { $0.date < $1.date }).first?.date,
                  let rhsDate = $1.value.sorted(by: { $0.date < $1.date }).first?.date else {
                return false
            }
            return lhsDate < rhsDate
        }
        for (exerciseName, sets) in sortedGrouped {
            let workoutView = WeightWorkoutInputView()
            let workout = WeightWorkout(exerciseName: exerciseName, sets: sets.map {
                WeightWorkout.SetInfo(weight: $0.weight, reps: $0.repetitions)
            }, date: date)
            workoutView.configure(with: workout, date: date)
            workoutView.addTarget(self, action: #selector(handleInputViewTapped(_:)), for: .touchUpInside)
            contentStack.addArrangedSubview(workoutView)
        }

        
        calendarView.reloadDecorations(forDateComponents: [Calendar.current.dateComponents([.year, .month, .day], from: date)], animated: true)
        
        let hasWorkoutViews = contentStack.arrangedSubviews.contains(where: { $0 is WeightWorkoutInputView })
        emptyLabel.isHidden = hasWorkoutViews
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

// MARK: - 키보드 처리
private extension WeightWorkoutViewController {
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let bottomInset = keyboardFrame.height
        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    }

    @objc func keyboardWillHide(notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
