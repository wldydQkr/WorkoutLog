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

    private let lineChartView = LineChartView()

    init(exerciseName: String) {
        self.exerciseName = exerciseName
        super.init(nibName: nil, bundle: nil)
        fetchWorkoutData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        updateChartData()
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(lineChartView)

        titleLabel.text = "\(exerciseName) 기록"
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        lineChartView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(view.snp.width)
        }
    }

    private func fetchWorkoutData() {
        let realm = try! Realm()
        let results = realm.objects(WorkoutSetObject.self).filter("exerciseName == %@", exerciseName)

        var weightByDate: [Date: Double] = [:]
        let calendar = Calendar.current

        for workout in results {
            let day = calendar.startOfDay(for: workout.date)
            let currentMax = weightByDate[day] ?? 0
            weightByDate[day] = max(currentMax, workout.weight)
        }

        chartData = weightByDate.map { ($0.key, $0.value) }
        chartData.sort { $0.date < $1.date }
    }

    private func updateChartData() {
        var entries: [ChartDataEntry] = []
        for (index, data) in chartData.enumerated() {
            entries.append(ChartDataEntry(x: Double(index), y: data.maxWeight))
        }

        let dataSet = LineChartDataSet(entries: entries, label: "최고 중량 (kg)")
        dataSet.colors = [.systemBlue]
        dataSet.circleColors = [.systemBlue]
        dataSet.circleRadius = 4
        dataSet.lineWidth = 2
        dataSet.valueFont = .systemFont(ofSize: 12, weight: .medium)
        dataSet.mode = .cubicBezier

        let lineData = LineChartData(dataSet: dataSet)
        lineChartView.data = lineData
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.enabled = false
    }
}
