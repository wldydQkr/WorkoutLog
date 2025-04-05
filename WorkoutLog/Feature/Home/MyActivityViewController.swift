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
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        navigationItem.hidesBackButton = true
        navigationController?.setNavigationBarHidden(true, animated: false)

        let titleLabel = UILabel().then {
            $0.text = "WorkoutLog"
            $0.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            $0.textColor = .black
        }

        let profileImageView = UIImageView().then {
            $0.image = UIImage(systemName: "person.circle") // Replace with actual image later
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 15
            $0.tintColor = .black
            $0.snp.makeConstraints {
                $0.width.height.equalTo(30)
            }
        }

        let stackView = UIStackView(arrangedSubviews: [titleLabel, profileImageView]).then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 8
        }

        navigationItem.titleView = stackView

        view.addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
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
            let width = collectionView.frame.width - 20 // 10pt inset on both sides
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
