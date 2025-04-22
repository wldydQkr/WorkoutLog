//
//  ExerciseObject.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/20/25.
//

import UIKit
import RealmSwift

class ExerciseObject: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String
    @Persisted var category: String
}
