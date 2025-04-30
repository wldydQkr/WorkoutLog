//
//  WorkoutChartDetailViewModel.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/30/25.
//

import Foundation
import RealmSwift

final class WorkoutChartDetailViewModel {

    func loadChartData(for exerciseName: String) -> [(date: Date, maxWeight: Double)] {
        // 종목명에서 카테고리 구분자 제거 및 공백 제거
        let trimmedExerciseName = exerciseName
            .components(separatedBy: "|").last?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? exerciseName

        // Realm 객체 가져오기
        let realm = try! Realm()
        let results = realm.objects(WorkoutSetObject.self)
            .filter("exerciseName == %@", trimmedExerciseName)

        // 날짜별 최대 중량 계산
        var weightByDate: [Date: Double] = [:]
        let calendar = Calendar.current

        for workout in results {
            let day = calendar.startOfDay(for: workout.date)
            let currentMax = weightByDate[day] ?? 0
            weightByDate[day] = max(currentMax, workout.weight)
        }

        // 차트 데이터 정렬 및 최근 5개 추출
        let sortedChartData = weightByDate
            .map { (date: $0.key, maxWeight: $0.value) }
            .sorted { $0.date < $1.date }

        return sortedChartData.suffix(5)
    }
}
