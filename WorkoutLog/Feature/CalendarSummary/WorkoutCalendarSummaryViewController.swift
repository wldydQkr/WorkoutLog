//
//  WorkoutCalendarSummaryViewController.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/15/25.
//

import UIKit
import RealmSwift
import SnapKit
import Then

final class WorkoutCalendarSummaryViewController: UIViewController {

    private let calendarView = UICalendarView().then {
        $0.calendar = Calendar(identifier: .gregorian)
        $0.locale = Locale(identifier: "ko_KR")
        $0.fontDesign = .monospaced
    }
    
    private let scrollView = UIScrollView()
    private let scrollContentStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 20  // Previously 24, adjusted for better compactness
    }

    private let contentView = UIView().then {
        $0.backgroundColor = UIColor.systemGray6
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }

    private let summaryLabel = UILabel().then {
        $0.text = "날짜를 선택하세요"
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.textColor = .label
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private let exerciseListLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()

        calendarView.delegate = self
        calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)

        let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        (calendarView.selectionBehavior as? UICalendarSelectionSingleDate)?.setSelected(today, animated: false)
        if let todayDate = Calendar.current.date(from: today) {
            updateSummary(for: todayDate)
        }
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentStack)
        
        [calendarView, contentView].forEach {
            scrollContentStack.addArrangedSubview($0)
        }
        let labelStack = UIStackView(arrangedSubviews: [summaryLabel, exerciseListLabel]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }
        contentView.addSubview(labelStack)
        
        labelStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        scrollContentStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
            $0.width.equalToSuperview().inset(16)
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(calendarView.snp.width).multipliedBy(1.0)
        }

        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
    }

    private func updateSummary(for date: Date) {
        let realm = try! Realm()
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let workouts = realm.objects(WorkoutSetObject.self)
            .filter("date >= %@ AND date < %@", startOfDay, endOfDay)

        if workouts.isEmpty {
            summaryLabel.text = "해당 날짜에 기록된 운동이 없습니다."
            exerciseListLabel.text = ""
        } else {
            let totalVolume = workouts.reduce(0.0) { $0 + ($1.weight * Double($1.repetitions)) }
            summaryLabel.text = "운동 기록 수: \(workouts.count)\n총 볼륨: \(Int(totalVolume))kg"
            let exerciseNames = Set(workouts.map { $0.exerciseName })
            exerciseListLabel.text = "운동 종목: " + exerciseNames.joined(separator: ", ")
        }
    }
}

extension WorkoutCalendarSummaryViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        guard let date = Calendar.current.date(from: dateComponents) else { return nil }

        let realm = try! Realm()
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let hasData = !realm.objects(WorkoutSetObject.self)
            .filter("date >= %@ AND date < %@", startOfDay, endOfDay)
            .isEmpty

        return hasData ? .default(color: .systemBlue) : nil
    }
}

extension WorkoutCalendarSummaryViewController: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let components = dateComponents,
              let date = Calendar.current.date(from: components) else { return }
        updateSummary(for: date)
    }
}
