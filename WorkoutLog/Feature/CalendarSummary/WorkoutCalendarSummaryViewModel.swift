//
//  WorkoutCalendarSummaryViewModel.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/19/25.
//

import Foundation
import RealmSwift

final class WorkoutCalendarSummaryViewModel {
    
    func summary(for date: Date) -> (summaryText: String, exerciseList: String) {
        let realm = try! Realm()
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let workouts = realm.objects(WorkoutSetObject.self)
            .filter("date >= %@ AND date < %@", startOfDay, endOfDay)

        if workouts.isEmpty {
            return ("해당 날짜에 기록된 운동이 없습니다.", "")
        } else {
            let totalVolume = workouts.reduce(0.0) { $0 + ($1.weight * Double($1.repetitions)) }
            let summaryText = "운동 기록 수: \(workouts.count)\n총 볼륨: \(Int(totalVolume))kg"
            let exerciseNames = Set(workouts.map { $0.exerciseName })
            let exerciseList = "운동 종목: " + exerciseNames.joined(separator: ", ")
            return (summaryText, exerciseList)
        }
    }

    func hasData(on date: Date) -> Bool {
        let realm = try! Realm()
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        return !realm.objects(WorkoutSetObject.self)
            .filter("date >= %@ AND date < %@", startOfDay, endOfDay)
            .isEmpty
    }
}
