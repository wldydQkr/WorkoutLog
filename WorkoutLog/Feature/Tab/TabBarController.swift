//
//  TabBarController.swift
//  WorkoutLog
//
//  Created by 박지용 on 3/31/25.
//

import UIKit

//final class TabBarController: UITabBarController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupTabs()
//    }
//
//    private func setupTabs() {
//        let homeVC = UINavigationController(rootViewController: MyActivityViewController())
//        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
//
//        let activityVC = UINavigationController(rootViewController: MyActivityViewController())
//        activityVC.tabBarItem = UITabBarItem(title: "Activity", image: UIImage(systemName: "heart.fill"), tag: 1)
//
//        let searchVC = UINavigationController(rootViewController: MyActivityViewController())
//        searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
//
//        viewControllers = [homeVC, activityVC, searchVC]
//
//        tabBar.tintColor = .black
//        tabBar.backgroundColor = .white
//    }
//}

final class CustomTabBarController: UITabBarController {

    private let floatingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .white
        button.tintColor = .black
//        button.titleLabel?.font = .systemFont(ofSize: 40, weight: .bold)
        button.layer.cornerRadius = 35
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 4
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupFloatingButton()
    }

    private func setupTabs() {
        let homeVC = UINavigationController(rootViewController: MyActivityViewController())
        homeVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), tag: 0)

        let activityVC = UINavigationController(rootViewController: MyActivityViewController())
        activityVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "heart.fill"), tag: 1)

        let placeholderVC = UIViewController()
        placeholderVC.tabBarItem = UITabBarItem(title: nil, image: nil, tag: 2)

        let locationVC = UINavigationController(rootViewController: MyActivityViewController())
        locationVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "mappin"), tag: 3)

        let searchVC = UINavigationController(rootViewController: MyActivityViewController())
        searchVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "magnifyingglass"), tag: 4)

        viewControllers = [homeVC, activityVC, placeholderVC, locationVC, searchVC]
        tabBar.tintColor = .darkGray
        tabBar.unselectedItemTintColor = .lightGray
        tabBar.backgroundColor = .clear
    }

    private func setupFloatingButton() {
        view.addSubview(floatingButton)
        floatingButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            floatingButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            floatingButton.widthAnchor.constraint(equalToConstant: 70),
            floatingButton.heightAnchor.constraint(equalToConstant: 70)
        ])

        floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
    }

    @objc private func floatingButtonTapped() {
        print("플로팅 버튼 클릭됨")
    }
}
