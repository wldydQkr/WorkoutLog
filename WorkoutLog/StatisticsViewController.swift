//
//  StatisticsViewController.swift
//  WorkoutLog
//
//  Created by 박지용 on 3/29/25.
//

import UIKit

class StatisticsViewController: UIViewController {
    private let viewModel = StatisticsViewModel()
    
    private let progressLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        progressLabel.text = "\(viewModel.statistics.percentage)%"
        progressLabel.font = UIFont.boldSystemFont(ofSize: 24)
        progressLabel.textAlignment = .center
        
        view.addSubview(progressLabel)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
