//
//  TabBarController.swift
//  SwiftExample
//
//  Created by Timur Ganiev on 09.12.2020.
//  Copyright © 2020 Timur Ganiev. All rights reserved.
//

import UIKit
import TBTabBarController

class TabBarController: TBTabBarController {
    
    // MARK: - Public
    
    // MARK: Overrides

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Make the bottom tab bar translucent
        
        horizontalTabBar.backgroundColor = .clear
        horizontalTabBar.contentView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        
        
    }
    
    override func preferredTabBarPosition(forViewSize size: CGSize) -> TBTabBarControllerTabBarPosition {
        
        // Show the vertical tab bar whenever the device orientation is landscape
        
        return size.width >= size.height ? .leading : .bottom
    }
}
