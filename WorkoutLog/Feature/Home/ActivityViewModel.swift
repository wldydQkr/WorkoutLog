import Foundation
import HealthKit

class ActivityViewModel {
    private let healthStore = HKHealthStore()
    private(set) var activities: [Activity] = []
    var onDataUpdated: (() -> Void)?

    init() {
        requestAuthorization()
    }

    private func requestAuthorization() {
        let readTypes: Set = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKQuantityType.quantityType(forIdentifier: .dietaryWater)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]

        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            if success {
                self.fetchHealthData()
            }
        }
    }

    func fetchHealthData() {
        var updatedActivities: [String: Activity] = [:]

        let group = DispatchGroup()

        group.enter()
        fetchStepCount { steps, goal in
            updatedActivities["Steps"] = Activity(title: "걸음 수", value: "\(Int(steps))", goal: goal != nil ? "\(Int(goal!))" : nil, icon: "steps_icon")
            group.leave()
        }

        group.enter()
        fetchHeartRate { heartRate in
            updatedActivities["Heart Rate"] = Activity(title: "심박수", value: "\(Int(heartRate)) bpm", goal: nil, icon: "heart_icon")
            group.leave()
        }

        group.enter()
        fetchActiveCalories { calories, goal in
            updatedActivities["Calories"] = Activity(title: "칼로리", value: "\(Int(calories)) kcal", goal: goal != nil ? "\(Int(goal!)) kcal" : nil, icon: "calories_icon")
            group.leave()
        }

        group.enter()
        fetchWaterIntake { water, goal in
            updatedActivities["Water"] = Activity(title: "물 섭취량", value: "\(water)리터", goal: "\(goal ?? 0)리터", icon: "water_icon")
            group.leave()
        }

        group.notify(queue: .main) {
            let orderedKeys = ["Steps", "Heart Rate", "Calories", "Water"]
            self.activities = orderedKeys.compactMap { updatedActivities[$0] }
            self.onDataUpdated?()
        }
    }

    private func fetchStepCount(completion: @escaping (Double, Double?) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let stepCount = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0

            let goal = 6000.0 // 목표 걸음 수 (추후 사용자 설정 값으로 변경 가능)
            completion(stepCount, goal)
        }

        healthStore.execute(query)
    }

    private func fetchHeartRate(completion: @escaping (Double) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
            let heartRate = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit(from: "count/min")) ?? 0
            completion(heartRate)
        }

        healthStore.execute(query)
    }

    private func fetchActiveCalories(completion: @escaping (Double, Double?) -> Void) {
        let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let calories = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0

            let goal = 500.0 // 예시 목표 칼로리 (추후 사용자 설정 가능)
            completion(calories, goal)
        }

        healthStore.execute(query)
    }

    private func fetchWaterIntake(completion: @escaping (Double, Double?) -> Void) {
        let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: waterType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let water = result?.sumQuantity()?.doubleValue(for: HKUnit.liter()) ?? 0
            
            let goal = 2.0
            completion(water, goal)
        }

        healthStore.execute(query)
    }
}
