//
//  WorkoutChartDetailViewController.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/26/25.
//

import UIKit
import Charts
import SnapKit
import Then
import RealmSwift

class WorkoutChartDetailViewController: UIViewController {

    private let exerciseName: String
    private var chartData: [(date: Date, maxWeight: Double)] = []

    private let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 24)
        $0.textAlignment = .center
    }

    private let barChartView = BarChartView()

    init(exerciseName: String) {
        self.exerciseName = exerciseName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        fetchWorkoutData()
        updateChartData()
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(barChartView)

        let trimmedExerciseName = exerciseName
            .components(separatedBy: "|").last?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? exerciseName
        
        titleLabel.text = "\(trimmedExerciseName) 기록"
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        barChartView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(view.snp.width)
        }
    }

    private func fetchWorkoutData() {
        print("넘어온 exerciseName: \(exerciseName)")
        let realm = try! Realm()
        print("전체 WorkoutSetObject 확인 시작")
        for workout in realm.objects(WorkoutSetObject.self) {
            print("운동 이름: \(workout.exerciseName), 날짜: \(workout.date), 무게: \(workout.weight)")
        }
        print("전체 WorkoutSetObject 확인 끝")
        let trimmedExerciseName = exerciseName
            .components(separatedBy: "|").last?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? exerciseName
        let results = realm.objects(WorkoutSetObject.self).filter("exerciseName == %@", trimmedExerciseName)
        print("Realm results:", results.description)
        print("Realm results count:", results.count)
        
        var weightByDate: [Date: Double] = [:]
        let calendar = Calendar.current

        for workout in results {
            let day = calendar.startOfDay(for: workout.date)
            let currentMax = weightByDate[day] ?? 0
            weightByDate[day] = max(currentMax, workout.weight)
        }

        chartData = weightByDate.map { ($0.key, $0.value) }
        chartData.sort { $0.date < $1.date }
        
        if chartData.count > 5 {
            chartData = Array(chartData.suffix(5))
        }
        
        print("Chart Data Loaded:")
        for item in chartData {
            print("Date: \(item.date), Max Weight: \(item.maxWeight)")
        }
    }

    private func updateChartData() {
        var entries: [BarChartDataEntry] = []
        for (index, data) in chartData.enumerated() {
            entries.append(BarChartDataEntry(x: Double(index), y: data.maxWeight))
        }

        let dataSet = BarChartDataSet(entries: entries, label: "최고 중량 (kg)")
        dataSet.colors = [UIColor.systemBlue]
        dataSet.valueFont = .systemFont(ofSize: 12, weight: .medium)
        dataSet.valueFormatter = DefaultValueFormatter { (value, _, _, _) -> String in
            let intValue = Int(value)
            if Double(intValue) == value {
                return "\(intValue)kg"
            } else {
                return "\(String(format: "%.1f", value))kg"
            }
        }
        dataSet.highlightEnabled = false

        let barData = BarChartData(dataSet: dataSet)
        barData.barWidth = 0.4

        barChartView.data = barData

        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"

        barChartView.xAxis.centerAxisLabelsEnabled = false
        barChartView.xAxis.granularity = 1
        barChartView.xAxis.labelCount = chartData.count
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: chartData.map {
            formatter.string(from: $0.date)
        })
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.avoidFirstLastClippingEnabled = false

        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.axisMinimum = 0

        barChartView.legend.enabled = false
        barChartView.drawGridBackgroundEnabled = false
        barChartView.drawBordersEnabled = false
        barChartView.animate(yAxisDuration: 0.5)
        barChartView.fitBars = true
    }
}
