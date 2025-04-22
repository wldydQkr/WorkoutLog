//
//  WeightWorkoutViewModel.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/8/25.
//

import UIKit
import RealmSwift

// MARK: - ViewModel
final class WeightWorkoutViewModel {
    private(set) var workouts: [WeightWorkout] = []

    var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: Date())
    }

    func fetchWorkouts(for date: Date) -> [WeightWorkout] {
        let realm = try! Realm()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let results = realm.objects(WorkoutSetObject.self)
            .filter("date >= %@ AND date < %@", startOfDay, endOfDay)
            .sorted(byKeyPath: "sets")

        let grouped = Dictionary(grouping: results, by: { $0.exerciseName })

        return grouped.map { name, sets in
            WeightWorkout(
                exerciseName: name,
                sets: sets.map { WeightWorkout.SetInfo(weight: $0.weight, reps: $0.repetitions) },
                date: date
            )
        }
    }

    func existingExerciseNames(for date: Date) -> Set<String> {
        let realm = try! Realm()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let results = realm.objects(WorkoutSetObject.self)
            .filter("date >= %@ AND date < %@", startOfDay, endOfDay)
        return Set(results.map { $0.exerciseName })
    }

    func addWorkout(exerciseName: String, setInfos: [WeightWorkout.SetInfo], unit: String, date: Date) {
        let workout = WeightWorkout(exerciseName: exerciseName, sets: setInfos, unit: WeightWorkout.Unit(rawValue: unit) ?? .kg, date: date)
        workouts.append(workout)
    }

    func updateWorkout(id: UUID, setInfos: [WeightWorkout.SetInfo]) {
        if let index = workouts.firstIndex(where: { $0.id == id }) {
            var updatedWorkout = workouts[index]
            updatedWorkout.sets = setInfos
            workouts[index] = updatedWorkout
        }
    }

    func deleteWorkout(id: UUID) {
        workouts.removeAll { $0.id == id }
    }

    func fetchWorkouts() -> [WeightWorkout] {
        return workouts
    }

    func saveWorkout(exerciseName: String, setInfos: [WeightWorkout.SetInfo], date: Date) {
        let realm = try! Realm()
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        try? realm.write {
            let existing = realm.objects(WorkoutSetObject.self)
                .filter("exerciseName == %@ AND date >= %@ AND date < %@", exerciseName, startOfDay, endOfDay)
            realm.delete(existing)

            for (index, setInfo) in setInfos.enumerated() {
                let setObject = WorkoutSetObject()
                setObject.exerciseName = exerciseName
                setObject.weight = setInfo.weight
                setObject.repetitions = setInfo.reps
                setObject.sets = index + 1
                setObject.date = date
                realm.add(setObject)
            }
        }
    }
    
    
    // 선택한 날짜에 해당하는 운동 데이터를 그룹별로 반환
    func workoutGroups(for date: Date) -> [String: [WorkoutSetObject]] {
        let realm = try! Realm()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let results = realm.objects(WorkoutSetObject.self)
            .filter("date >= %@ AND date < %@", startOfDay, endOfDay)
            .sorted(byKeyPath: "sets")

        return Dictionary(grouping: results, by: { $0.exerciseName })
    }
}

//    func workoutGroups(for date: Date) -> [String: [WorkoutSetObject]] {
//        let realm = try! Realm()
//        let calendar = Calendar.current
//        let startOfDay = calendar.startOfDay(for: date)
//        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
//
//        let results = realm.objects(WorkoutSetObject.self)
//            .filter("date >= %@ AND date < %@", startOfDay, endOfDay)
//            .sorted(byKeyPath: "sets")
//
//        return Dictionary(grouping: results, by: { $0.exerciseName })
//    }
