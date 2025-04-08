//
//  WeightWorkout.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/8/25.
//

import Foundation

struct WeightWorkout: Identifiable, Codable, Equatable {
    let id: UUID
    var exerciseName: String
    var sets: Int
    var repetitions: Int
    var weight: Double
    var unit: Unit
    var date: Date

    enum Unit: String, Codable, CaseIterable {
        case kg = "kg"
        case lb = "lb"
    }

    init(id: UUID = UUID(), exerciseName: String, sets: Int, repetitions: Int, weight: Double, unit: Unit = .kg, date: Date = Date()) {
        self.id = id
        self.exerciseName = exerciseName
        self.sets = sets
        self.repetitions = repetitions
        self.weight = weight
        self.unit = unit
        self.date = date
    }
}
