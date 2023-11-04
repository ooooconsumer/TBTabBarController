//
//  TabBarController.swift
//  SwiftExample
//
//  Created by Timur Ganiev on 09.12.2020.
//  Copyright © 2020-2023 Timur Ganiev. All rights reserved.
//

import UIKit
import TBTabBarController

final class TabBarController: TBTabBarController {

    // MARK: Overrides

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Make the bottom tab bar translucent
        
        horizontalTabBar.backgroundColor = .clear
        horizontalTabBar.contentView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    }

    override func preferredTabBarPlacement(
        forViewSize size: CGSize
    ) -> TBTabBarControllerTabBarPlacement {
        
        // Show the vertical tab bar whenever the device orientation is landscape
        
        return size.width >= size.height ? .leading : .bottom
    }
}
