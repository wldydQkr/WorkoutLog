//
//  RoutineCollectionViewCell.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/5/25.
//

import UIKit

class RoutineCollectionViewCell: UICollectionViewCell {
    static let identifier = "RoutineCollectionViewCell"

    private let iconImageView = UIImageView().then {
        $0.image = UIImage(systemName: "plus.circle.fill")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .lightGray
        $0.snp.makeConstraints { $0.size.equalTo(24) }
    }

    private let titleLabel = UILabel().then {
        $0.text = "루틴 · 폴더 만들기"
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .gray
    }

    private let startButton = UIButton().then {
        $0.setTitle("운동 바로 시작", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
//        $0.backgroundColor = .black
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.gray.cgColor, UIColor.black.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 400, height: 48)
        $0.layer.insertSublayer(gradientLayer, at: 0)
    }

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
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4

        let titleStack = UIStackView(arrangedSubviews: [iconImageView, titleLabel]).then {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
        }

        let mainStack = UIStackView(arrangedSubviews: [titleStack, startButton]).then {
            $0.axis = .vertical
            $0.spacing = 16
            $0.alignment = .center
        }

        contentView.addSubview(mainStack)
        mainStack.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        startButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    func configure(with activity: Activity) {
        titleLabel.text = activity.title
    }
}
