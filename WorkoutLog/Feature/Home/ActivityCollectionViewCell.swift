//
//  ActivityCollectionViewCell.swift
//  WorkoutLog
//
//  Created by 박지용 on 3/29/25.
//

import UIKit

class ActivityCollectionViewCell: UICollectionViewCell {
    static let identifier = "ActivityCell"
    
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 12
        contentView.backgroundColor = .white
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowRadius = 5
        
        iconImageView.contentMode = .scaleAspectFit
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        valueLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel, valueLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 5
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with activity: Activity) {
        titleLabel.text = activity.title
        valueLabel.text = activity.value
        iconImageView.image = UIImage(named: activity.icon)
    }
}
