//
//  TabBarController.swift
//  WorkoutLog
//
//  Created by 박지용 on 3/31/25.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let homeVC = UINavigationController(rootViewController: MyActivityViewController())
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)

        let activityVC = UINavigationController(rootViewController: MyActivityViewController())
        activityVC.tabBarItem = UITabBarItem(title: "Activity", image: UIImage(systemName: "heart.fill"), tag: 1)

        let searchVC = UINavigationController(rootViewController: MyActivityViewController())
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)

        viewControllers = [homeVC, activityVC, searchVC]

        tabBar.tintColor = .black
        tabBar.backgroundColor = .white
    }
}
