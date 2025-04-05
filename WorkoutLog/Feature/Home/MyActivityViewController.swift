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
    }

    private let viewModel = ActivityViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        navigationController?.navigationBar.isHidden = true

        view.addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().offset(-80)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActivityCollectionViewCell.identifier, for: indexPath) as! ActivityCollectionViewCell
        let activity = viewModel.activities[indexPath.row]
        
        if activity.title == "걸음 수" {
            cell.configure(with: activity)
        } else {
            cell.configure(with: activity)
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 2
        let spacing: CGFloat = 10
        let totalSpacing = (itemsPerRow - 1) * spacing
        let availableWidth = collectionView.frame.width - totalSpacing - 20
        let itemWidth = availableWidth / itemsPerRow
        return CGSize(width: itemWidth, height: itemWidth * 1.2)
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
