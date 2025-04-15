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
        $0.fontDesign = .rounded
    }

    private let summaryLabel = UILabel().then {
        $0.text = "날짜를 선택하세요"
        $0.font = .systemFont(ofSize: 16)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()

        calendarView.delegate = self
        calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
    }

    private func setupUI() {
        view.addSubview(calendarView)
        view.addSubview(summaryLabel)

        calendarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(calendarView.snp.width).multipliedBy(1.2)
        }

        summaryLabel.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
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
        } else {
            let totalVolume = workouts.reduce(0.0) { $0 + ($1.weight * Double($1.repetitions)) }
            summaryLabel.text = "운동 기록 수: \(workouts.count)\n총 볼륨: \(Int(totalVolume))kg"
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
