//
//  UIViewController+.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/19/25.
//

import UIKit

extension UIViewController {
    func setTransparentStatusBar() {
        if let statusBarFrame = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.statusBarManager?.statusBarFrame {
            let statusBarView = UIView(frame: statusBarFrame)
            statusBarView.backgroundColor = .clear
            view.addSubview(statusBarView)
        }
    }
}
