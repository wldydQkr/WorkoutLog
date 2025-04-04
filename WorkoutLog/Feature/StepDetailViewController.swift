//
//  StepDetailViewController.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/4/25.
//

import UIKit
import SnapKit

class StepsDetailViewController: UIViewController {
    private let steps: Int
    private let goal: Int?

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
//        view.backgroundColor = .white
        setupUI()
        
        print("viewDidLoad called, UI should be set up")

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
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
