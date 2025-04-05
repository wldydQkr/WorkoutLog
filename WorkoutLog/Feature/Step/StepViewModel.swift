//
//  StepViewModel.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/5/25.
//

import Foundation
import HealthKit

class StepViewModel {
    private let healthStore = HKHealthStore()
    
    func requestHealthKitAccess(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let durationType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!

        let readTypes: Set<HKObjectType> = [stepType, distanceType, durationType]
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, _ in
            completion(success)
        }
    }

    func fetchDistanceAndDuration(completion: @escaping (Double, Double) -> Void) {
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let durationType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let distanceQuery = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let distance = result?.sumQuantity()?.doubleValue(for: .meter()) ?? 0.0

            let durationQuery = HKStatisticsQuery(quantityType: durationType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let duration = result?.sumQuantity()?.doubleValue(for: .minute()) ?? 0.0

                DispatchQueue.main.async {
                    completion(distance / 1000.0, duration) // 거리: km, 시간: 분
                }
            }

            self.healthStore.execute(durationQuery)
        }

        healthStore.execute(distanceQuery)
    }

    func fetchStepData(completion: @escaping ([Int: Int]) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion([:])
            return
        }

        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        var interval = DateComponents()
        interval.hour = 1

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: [.cumulativeSum],
            anchorDate: startOfDay,
            intervalComponents: interval
        )

        query.initialResultsHandler = { _, results, _ in
            var stepData: [Int: Int] = [:]
            results?.enumerateStatistics(from: startOfDay, to: now) { stat, _ in
                let hour = calendar.component(.hour, from: stat.startDate)
                let count = Int(stat.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                stepData[hour] = count
            }

            DispatchQueue.main.async {
                completion(stepData)
            }
        }

        healthStore.execute(query)
    }
}
