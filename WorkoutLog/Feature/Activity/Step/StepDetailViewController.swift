//
//  StepDetailViewController.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/4/25.
//

import UIKit
import SnapKit
import Charts
import HealthKit
import UICircularProgressRing
import Then

class StepsDetailViewController: UIViewController {
    private let steps: Int
    private let goal: Int?
    private let viewModel = StepViewModel()
    private let lineChartView = LineChartView()
    private let progressRing = UICircularProgressRing()

    private let stepsLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 24)
        $0.textAlignment = .center
    }

    private let distanceLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 24)
        $0.textAlignment = .center
    }

    private let durationLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 24)
        $0.textAlignment = .center
    }

    private let stepsUnitLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textAlignment = .center
        $0.text = "Steps"
    }

    private let distanceUnitLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textAlignment = .center
        $0.text = "km"
    }

    private let durationUnitLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textAlignment = .center
        $0.text = "min"
    }

    private let infoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 20
        $0.alignment = .center
        $0.distribution = .equalSpacing
    }

    init(steps: Int, goal: Int?) {
        self.steps = steps
        self.goal = goal
        super.init(nibName: nil, bundle: nil)
        
        print("StepsDetailViewController initialized with steps: \(steps), goal: \(String(describing: goal))")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        setupUI()
        viewModel.requestHealthKitAccess { success in
            if !success {
                print("HealthKit authorization failed.")
            }
        }
        setupChart()
    }
  
    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "걸음 수"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let percentage = goal != nil ? (Double(steps) / Double(goal!) * 100) : 100

        progressRing.maxValue = 100
        progressRing.innerRingColor = .black
        progressRing.outerRingColor = UIColor.lightGray.withAlphaComponent(0.3)
        progressRing.startAngle = -90
        progressRing.font = UIFont.boldSystemFont(ofSize: 18)
        progressRing.style = .ontop
        progressRing.value = CGFloat(percentage)
        progressRing.minValue = 0

        let ringContainer = UIView()
        ringContainer.addSubview(progressRing)
        
        ringContainer.snp.makeConstraints {
            $0.width.height.equalTo(120)
        }

        progressRing.snp.makeConstraints {
            $0.width.height.equalTo(120)
            $0.center.equalToSuperview()
        }

        stepsLabel.text = "\(steps)"
        
        distanceLabel.text = "Loading..."
        durationLabel.text = "Loading..."
        viewModel.fetchDistanceAndDuration { distance, duration in
            self.distanceLabel.text = String(format: "%.2f", distance)
            self.durationLabel.text = String(format: "%.0f", duration)
        }

        let stackView = UIStackView(arrangedSubviews: [titleLabel, ringContainer, infoStackView])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center

        let stepsStackView = UIStackView(arrangedSubviews: [stepsLabel, stepsUnitLabel])
        stepsStackView.axis = .vertical
        stepsStackView.alignment = .center

        let distanceStackView = UIStackView(arrangedSubviews: [distanceLabel, distanceUnitLabel])
        distanceStackView.axis = .vertical
        distanceStackView.alignment = .center

        let durationStackView = UIStackView(arrangedSubviews: [durationLabel, durationUnitLabel])
        durationStackView.axis = .vertical
        durationStackView.alignment = .center

        [stepsStackView, distanceStackView, durationStackView].forEach {
            infoStackView.addArrangedSubview($0)
        }

        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        lineChartView.noDataText = "Loading step data..."
        view.addSubview(lineChartView)
        lineChartView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(300)
        }
    }
    
    private func setupChart() {
        viewModel.fetchStepData { stepData in
            DispatchQueue.main.async {
                var entries: [ChartDataEntry] = []
                for (hour, stepCount) in stepData {
                    entries.append(ChartDataEntry(x: Double(hour), y: Double(stepCount)))
                }

                let dataSet = LineChartDataSet(entries: entries, label: "Hourly Steps")
                dataSet.colors = [.black]
                dataSet.circleColors = [.black]
                dataSet.circleRadius = 4.0
                dataSet.lineWidth = 2.0
                dataSet.valueFont = .systemFont(ofSize: 12)

                let data = LineChartData(dataSet: dataSet)
                self.lineChartView.data = data
            }
        }
    }
}
