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

class StepsDetailViewController: UIViewController {
    private let steps: Int
    private let goal: Int?
    private let healthStore = HKHealthStore()
    private let lineChartView = LineChartView()

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
        setupUI()
        requestHealthKitAccess()
        setupChart()
    }
  
    private func requestHealthKitAccess() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        healthStore.requestAuthorization(toShare: nil, read: [stepType]) { success, error in
            if !success {
                print("HealthKit authorization failed: \(String(describing: error))")
            }
        }
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "Walk"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let progressLabel = UILabel()
        let percentage = goal != nil ? (Double(steps) / Double(goal!) * 100) : 100
        progressLabel.text = "\(Int(percentage))%"
        progressLabel.font = .boldSystemFont(ofSize: 48)
        progressLabel.textAlignment = .center
        progressLabel.numberOfLines = 0

        let stepsLabel = UILabel()
        stepsLabel.text = "\(steps) Steps"
        stepsLabel.font = .systemFont(ofSize: 18)
        stepsLabel.textAlignment = .center
        stepsLabel.numberOfLines = 0

        let stackView = UIStackView(arrangedSubviews: [titleLabel, progressLabel, stepsLabel])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center

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
        // Removed the lineChartView creation from here
        fetchStepData { stepData in
            DispatchQueue.main.async {
                var entries: [ChartDataEntry] = []
                for (hour, stepCount) in stepData {
                    entries.append(ChartDataEntry(x: Double(hour), y: Double(stepCount)))
                }
                
                let dataSet = LineChartDataSet(entries: entries, label: "Hourly Steps")
                dataSet.colors = [.systemBlue]
                dataSet.circleColors = [.systemBlue]
                dataSet.circleRadius = 4.0
                dataSet.lineWidth = 2.0
                dataSet.valueFont = .systemFont(ofSize: 12)
                
                let data = LineChartData(dataSet: dataSet)
                self.lineChartView.data = data
            }
        }
    }
    
    private func fetchStepData(completion: @escaping ([(Int, Int)]) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion([])
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        guard let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now) else {
            completion([])
            return
        }
        
        var stepData: [(Int, Int)] = []
        let dispatchGroup = DispatchGroup()
        
        for hour in 0..<24 {
            dispatchGroup.enter()
            guard let startHour = calendar.date(byAdding: .hour, value: hour, to: startOfDay),
                  let endHour = calendar.date(byAdding: .hour, value: 1, to: startHour) else {
                dispatchGroup.leave()
                continue
            }
            
            let predicate = HKQuery.predicateForSamples(withStart: startHour, end: endHour, options: .strictStartDate)
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let stepCount = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                stepData.append((hour, Int(stepCount)))
                dispatchGroup.leave()
            }
            
            healthStore.execute(query)
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(stepData.sorted { $0.0 < $1.0 }) // Ensure data is in order
        }
    }
}
