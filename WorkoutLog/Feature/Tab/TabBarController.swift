//
//  TabBarController.swift
//  WorkoutLog
//
//  Created by 박지용 on 3/31/25.
//

import UIKit

final class CustomTabBarController: UITabBarController {

    private let floatingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .white
        button.tintColor = .black
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 4
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupTabs()
//        setupFloatingButton()
    }

    private func setupTabs() {
        let homeVC = UINavigationController(rootViewController: WeightWorkoutViewController())
        homeVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "figure.run"), tag: 0)

        let activityVC = UINavigationController(rootViewController: MyActivityViewController())
        activityVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "chart.bar.xaxis"), tag: 1)

        let placeholderVC = UIViewController()
        placeholderVC.tabBarItem = UITabBarItem(title: nil, image: nil, tag: 2)

        let locationVC = UINavigationController(rootViewController: WorkoutCalendarSummaryViewController())
        locationVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "calendar"), tag: 3)

        let searchVC = UINavigationController(rootViewController: SettingViewController())
        searchVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person.fill"), tag: 4)

        viewControllers = [homeVC, activityVC, locationVC, searchVC]
        tabBar.tintColor = .darkGray
        tabBar.unselectedItemTintColor = .lightGray
        tabBar.backgroundColor = .clear
    }

    // 탭바 아이템 선택 시 아이콘에 애니메이션 적용
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item),
              let tabBarButton = tabBar.subviews.filter({ $0 is UIControl })[safe: index] else { return }

        for subview in tabBarButton.subviews {
            if let imageView = subview as? UIImageView {
                UIView.animate(withDuration: 0.1, animations: {
                    imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }) { _ in
                    UIView.animate(withDuration: 0.1) {
                        imageView.transform = CGAffineTransform.identity
                    }
                }
                break
            }
        }
    }

    private func setupFloatingButton() {
        view.addSubview(floatingButton)
        floatingButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            floatingButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            floatingButton.widthAnchor.constraint(equalToConstant: 60),
            floatingButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
    }

    @objc private func floatingButtonTapped() {
        print("플로팅 버튼 클릭됨")
    }
}

// Safely access array/collection elements
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#if DEBUG
import SwiftUI

struct CustomTabBarController_Preview: PreviewProvider {
    static var previews: some View {
        CustomTabBarControllerPreview()
            .edgesIgnoringSafeArea(.all)
    }

    struct CustomTabBarControllerPreview: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UIViewController {
            return CustomTabBarController()
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            // no-op
        }
    }
}
#endif
