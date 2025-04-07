//
//  MyActivityViewController.swift
//  WorkoutLog
//
//  Created by 박지용 on 3/29/25.
//

import UIKit
import SnapKit
import Then

class MyActivityViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        $0.collectionViewLayout = layout
        $0.backgroundColor = .clear
        $0.dataSource = self
        $0.delegate = self
        $0.register(ActivityCollectionViewCell.self, forCellWithReuseIdentifier: ActivityCollectionViewCell.identifier)
        $0.register(RoutineCollectionViewCell.self, forCellWithReuseIdentifier: RoutineCollectionViewCell.identifier)
    }

    private let viewModel = ActivityViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)

        let headerView = UIView().then {
            $0.backgroundColor = .clear
        }

        let titleLabel = UILabel().then {
            $0.text = "WorkoutLog"
            $0.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            $0.textColor = .black
        }

        let profileImageView = UIImageView().then {
            $0.image = UIImage(systemName: "person.circle")
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 15
            $0.tintColor = .black
        }

        let stackView = UIStackView(arrangedSubviews: [titleLabel, profileImageView]).then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 8
        }

        headerView.addSubview(stackView)
        view.addSubview(headerView)

        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }

        stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }

        profileImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(16)
            $0.width.height.equalTo(30)
        }

        view.addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(10)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            $0.bottom.equalToSuperview()
        }

        viewModel.onDataUpdated = { [weak self] in
            self?.collectionView.reloadData()
        }

        viewModel.fetchHealthData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.activities.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let activity = viewModel.activities[indexPath.row]

        if activity.title == "루틴" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoutineCollectionViewCell.identifier, for: indexPath) as! RoutineCollectionViewCell
            cell.configure(with: activity)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActivityCollectionViewCell.identifier, for: indexPath) as! ActivityCollectionViewCell
            cell.configure(with: activity)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let activity = viewModel.activities[indexPath.row]

        if activity.title == "루틴" {
            let width = collectionView.frame.width - 20
            return CGSize(width: width, height: 150)
        } else {
            let itemsPerRow: CGFloat = 2
            let spacing: CGFloat = 10
            let totalSpacing = (itemsPerRow - 1) * spacing
            let availableWidth = collectionView.frame.width - totalSpacing - 20
            let itemWidth = availableWidth / itemsPerRow
            return CGSize(width: itemWidth, height: itemWidth * 1.2)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedActivity = viewModel.activities[indexPath.row]

        if selectedActivity.title == "걸음 수" {
            let detailVC = StepsDetailViewController(
                steps: Int(selectedActivity.value),
                goal: Int(selectedActivity.goal ?? 0.0)
            )
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
