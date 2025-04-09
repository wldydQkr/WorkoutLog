//
//  WeightWorkoutViewModel.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/8/25.
//

import UIKit

// MARK: - ViewModel
class WeightWorkoutViewModel {
    private(set) var workouts: [WeightWorkout] = []
    
    var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: Date())
    }

    func addWorkout(exerciseName: String, sets: Int, repetitions: Int, weight: Double, unit: String, date: Date) {
        let workout = WeightWorkout(exerciseName: exerciseName, sets: sets, repetitions: repetitions, weight: weight, unit: WeightWorkout.Unit(rawValue: unit) ?? .kg, date: date)
        workouts.append(workout)
    }

    func updateWorkout(id: UUID, sets: Int, repetitions: Int, weight: Double) {
        if let index = workouts.firstIndex(where: { $0.id == id }) {
            var updatedWorkout = workouts[index]
            updatedWorkout.sets = sets
            updatedWorkout.repetitions = repetitions
            updatedWorkout.weight = weight
            workouts[index] = updatedWorkout
        }
    }

    func deleteWorkout(id: UUID) {
        workouts.removeAll { $0.id == id }
    }

    func fetchWorkouts() -> [WeightWorkout] {
        return workouts
    }
}
