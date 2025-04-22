//
//  WorkoutSetObject.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/20/25.
//

import UIKit
import RealmSwift

//MARK: 운동 기록 DB
class WorkoutSetObject: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var exerciseName: String
    @Persisted var weight: Double
    @Persisted var repetitions: Int
    @Persisted var sets: Int
    @Persisted var date: Date
}
