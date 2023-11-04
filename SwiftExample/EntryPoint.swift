//
//  EntryPoint.swift
//  SwiftExample
//
//  Created by Timur Ganiev on 09.12.2020.
//  Copyright © 2020-2023 Timur Ganiev. All rights reserved.
//

import UIKit

final class EntryPoint {

    // MARK: Lifecycle

    @available(*, unavailable)
    init() { }

    // MARK: Public Methods

    static func start(with window: UIWindow) {
        
        let viewControllers = (0 ..< 5).map { makeTab(forItemAt: $0) }
        
        let tabBarController = TabBarController()
        tabBarController.viewControllers = viewControllers
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            tabBarController.viewControllers![0].tb_tabBarItem.showsNotificationIndicator = true
            tabBarController.viewControllers![1].tb_tabBarItem.showsNotificationIndicator = true
        }
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

// MARK: Private Methods

private extension EntryPoint {

    static func makeTab(forItemAt index: Int) -> UIViewController {

        let tabViewController = TabViewController()
        tabViewController.title  = "View Controller #\(index)"

        let navigationController = UINavigationController(rootViewController: tabViewController)
        navigationController.tb_tabBarItem.image = makeTabBarItemIconImage()

        return navigationController
    }

    static func makeTabBarItemIconImage() -> UIImage {
        
        let size = CGSize(width: 25.0, height: 25.0)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { rendererContext in
            let context = rendererContext.cgContext
            context.addEllipse(in: CGRect(origin: .zero, size: size))
            context.fillPath()
        }
        
        return image.withRenderingMode(.alwaysTemplate)
    }
}
