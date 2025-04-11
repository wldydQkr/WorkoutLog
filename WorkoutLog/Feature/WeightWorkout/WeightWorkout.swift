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
    var sets: [SetInfo]
    var unit: Unit
    var date: Date

    struct SetInfo: Identifiable, Codable, Equatable {
        var id = UUID()
        var weight: Double
        var reps: Int
    }

    enum Unit: String, Codable, CaseIterable {
        case kg = "kg"
        case lb = "lb"
    }

    init(id: UUID = UUID(), exerciseName: String, sets: [SetInfo], unit: Unit = .kg, date: Date = Date()) {
        self.id = id
        self.exerciseName = exerciseName
        self.sets = sets
        self.unit = unit
        self.date = date
    }
}
