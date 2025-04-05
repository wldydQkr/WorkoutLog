//
//  ActivityCollectionViewCell.swift
//  WorkoutLog
//
//  Created by 박지용 on 3/29/25.
//

import UIKit
import UICircularProgressRing

class ActivityCollectionViewCell: UICollectionViewCell {
    static let identifier = "ActivityCollectionViewCell"
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        return label
    }()

    // 원형 프로그레스 뷰
    private let progressRing: UICircularProgressRing = {
        let ring = UICircularProgressRing()
        ring.style = .ontop
        ring.innerRingColor = .black
        ring.outerRingColor = UIColor.lightGray.withAlphaComponent(0.3)
        ring.startAngle = -90
        ring.font = UIFont.boldSystemFont(ofSize: 18)
        return ring
    }()

    private let goalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    private let unitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8)
        ])

        let valueStack = UIStackView(arrangedSubviews: [valueLabel, unitLabel])
        valueStack.axis = .vertical
        valueStack.alignment = .center
        valueStack.spacing = 2

        let mainStack = UIStackView(arrangedSubviews: [progressRing, valueStack, goalLabel])
        mainStack.axis = .vertical
        mainStack.alignment = .center
        mainStack.spacing = 10
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            progressRing.widthAnchor.constraint(equalToConstant: 80),
            progressRing.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with activity: Activity) {
        titleLabel.text = activity.title
        iconImageView.image = activity.icon
        
        progressRing.isHidden = false
        goalLabel.isHidden = false
        valueLabel.isHidden = false
        unitLabel.isHidden = false

        let value = activity.value
        let goal = activity.goal ?? 1.0

        switch activity.title {
        case "걸음 수":
            let percentage = min((value / goal) * 100, 100)
            progressRing.maxValue = 100
            progressRing.startProgress(to: CGFloat(percentage), duration: 1.0)
            goalLabel.text = "\(Int(goal))"
            valueLabel.text = "\(Int(value))"
//            unitLabel.text = "걸음"

        case "수면":
            progressRing.isHidden = true
            goalLabel.isHidden = true
            valueLabel.text = String(format: "%.1f", value)
            unitLabel.text = "시간"

        case "심박수":
            progressRing.isHidden = true
            goalLabel.isHidden = true
            valueLabel.text = "\(Int(value))"
            unitLabel.text = "bpm"

        case "칼로리":
            progressRing.maxValue = CGFloat(goal)
            progressRing.startProgress(to: CGFloat(value), duration: 1.0)
            goalLabel.text = "/\(Int(goal))"
            valueLabel.text = "\(Int(value))"
            unitLabel.text = "Kcal"

        default:
            progressRing.isHidden = true
            goalLabel.isHidden = true
            valueLabel.text = "\(value)"
            unitLabel.text = ""
        }
    }
}
