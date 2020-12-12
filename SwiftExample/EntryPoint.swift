//
//  EntryPoint.swift
//  SwiftExample
//
//  Created by Timur Ganiev on 09.12.2020.
//  Copyright © 2020 Timur Ganiev. All rights reserved.
//

import UIKit

class EntryPoint {
    
    // MARK: - Public
    
    weak private(set) var window: UIWindow?
    
    static let shared = EntryPoint()
    
    // MARK: Interface
    
    func setup(with window: UIWindow) {
        
        self.window = window
        
        var viewControllers = [UIViewController]()
        
        for index in 0..<5 {
            viewControllers.append(_navigationController(with: _tabViewController(for: index)))
        }
        
        let tabBarController = TabBarController()
        tabBarController.viewControllers = viewControllers
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            tabBarController.viewControllers![0].tb_tabBarItem.showsNotificationIndicator = true
            tabBarController.viewControllers![1].tb_tabBarItem.showsNotificationIndicator = true
        }
        
        window.rootViewController = tabBarController
        
        window.makeKeyAndVisible()
    }
    
    // MARK: - Private
    
    // MARK: Builders
    
    fileprivate func _tabViewController(for index: Int) -> TabViewController {
        
        let tabViewController = TabViewController()
        tabViewController.title  = "View Controller #\(index)"
        
        return tabViewController
    }
    
    fileprivate func _navigationController(with tabViewController: TabViewController) -> UINavigationController {
        
        let navigationController = UINavigationController(rootViewController: tabViewController)
        navigationController.tb_tabBarItem.image = _drawTabBarItemImage()
        
        return navigationController
    }
    
    // MARK: Helpers
    
    fileprivate func _drawTabBarItemImage() -> UIImage {
        
        let size = CGSize(width: 25.0, height: 25.0)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { (rendererContext) in
            let context = rendererContext.cgContext
            context.addEllipse(in: CGRect(origin: .zero, size: size))
            context.fillPath()
        }
        
        return image.withRenderingMode(.alwaysTemplate)
    }
}
