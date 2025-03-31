//
//  ActivityViewModel.swift
//  WorkoutLog
//
//  Created by 박지용 on 3/29/25.
//

import Foundation

class ActivityViewModel {
    private(set) var activities: [Activity] = [
        Activity(title: "Steps", value: "4255", goal: "6000", icon: "steps_icon"),
        Activity(title: "Sleep", value: "4.58 hour", goal: nil, icon: "sleep_icon"),
        Activity(title: "Water", value: "1.6 liters", goal: nil, icon: "water_icon"),
        Activity(title: "Heart Rate", value: "126 bpm", goal: nil, icon: "heart_icon"),
        Activity(title: "Calories", value: "325 kcal", goal: nil, icon: "calories_icon"),
        Activity(title: "Training", value: "0 min", goal: nil, icon: "training_icon")
    ]
}
