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
    private let chartTitleLabel = UILabel().then {
        $0.text = ""
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .darkGray
    }

    private let chartContainerView = UIView().then {
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1)
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
    }

    private let lineChartView = LineChartView()

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
        chartContainerView.addSubview(chartTitleLabel)
        chartContainerView.addSubview(lineChartView)

        let trimmedExerciseName = exerciseName
            .components(separatedBy: "|").last?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? exerciseName
        
        titleLabel.text = "\(trimmedExerciseName) 기록"
        chartTitleLabel.text = "\(trimmedExerciseName) 날짜별 최고중량"

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

        chartTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }

        lineChartView.snp.remakeConstraints {
            $0.top.equalTo(chartTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24) // 좌우 간격 조금 더 확보
            $0.bottom.equalToSuperview().inset(16)
        }
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
        var entries: [ChartDataEntry] = []
        for (index, data) in chartData.enumerated() {
            entries.append(ChartDataEntry(x: Double(index), y: data.maxWeight))
        }

        let dataSet = LineChartDataSet(entries: entries, label: "최고 중량 (kg)")
        dataSet.colors = [UIColor.orange]
        dataSet.circleColors = [UIColor.orange]
        dataSet.circleRadius = 4
        dataSet.lineWidth = 2
        dataSet.mode = .cubicBezier
        dataSet.drawValuesEnabled = true
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

        let lineData = LineChartData(dataSet: dataSet)
        lineChartView.data = lineData

        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"

        lineChartView.xAxis.centerAxisLabelsEnabled = false
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.labelCount = chartData.count
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: chartData.map {
            formatter.string(from: $0.date)
        })
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.avoidFirstLastClippingEnabled = false

        lineChartView.rightAxis.enabled = false
        lineChartView.leftAxis.enabled = false

        lineChartView.legend.enabled = false
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.drawBordersEnabled = false
        lineChartView.animate(yAxisDuration: 0.5)

        // 제스처 및 줌, 드래그 등 비활성화
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.pinchZoomEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.dragEnabled = false
        lineChartView.highlightPerTapEnabled = false
        lineChartView.highlightPerDragEnabled = false
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

}
