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
    private let viewModel = WorkoutChartDetailViewModel()

    private let headerView = UIView()
    private let backButton = UIButton(type: .system).then {
        let image = UIImage(systemName: "chevron.left")
        $0.setImage(image, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        $0.tintColor = .black
        $0.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    private let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 15)
        $0.textAlignment = .center
    }

    private let chartContainerView = UIView().then {
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1)
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
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
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)
        view.addSubview(chartContainerView)
        chartContainerView.addSubview(barChartView)

        let trimmedExerciseName = exerciseName
            .components(separatedBy: "|").last?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? exerciseName
        
        titleLabel.text = "\(trimmedExerciseName) 기록"

        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(30)
        }

        backButton.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.height.equalTo(30)
        }

        titleLabel.snp.remakeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }

        chartContainerView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        barChartView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
        
        barChartView.pinchZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.scaleXEnabled = false
        barChartView.scaleYEnabled = false
        barChartView.highlightPerTapEnabled = false
        barChartView.highlightPerDragEnabled = false
    }

    private func fetchWorkoutData() {
        print("넘어온 exerciseName: \(exerciseName)")
        chartData = viewModel.loadChartData(for: exerciseName)

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
        dataSet.colors = [UIColor.orange]
        dataSet.valueFont = .systemFont(ofSize: 12, weight: .medium)
        dataSet.valueFormatter = DefaultValueFormatter(block: { (value, _, _, _) -> String in
            let intValue = Int(value)
            if Double(intValue) == value {
                return "\(intValue)kg"
            } else {
                return "\(String(format: "%.1f", value))kg"
            }
        })
        dataSet.highlightEnabled = false

        let barData = BarChartData(dataSet: dataSet)
        barData.barWidth = 0.7

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
        barChartView.leftAxis.enabled = false

        barChartView.legend.enabled = false
        barChartView.drawGridBackgroundEnabled = false
        barChartView.drawBordersEnabled = false
        barChartView.animate(yAxisDuration: 0.5)
        barChartView.fitBars = true
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

}
