//
//  ToggleItem.swift
//  SwiftExample
//
//  Created by Timur Ganiev on 26.01.2023.
//  Copyright © 2023 Timur Ganiev. All rights reserved.
//

import Foundation

enum ToggleItem {
    case hideTabBarOnPush(isOn: Bool)
    case showNotificationIndicator(isOn: Bool)
}

extension ToggleItem {

    var title: String {
        switch self {
        case .hideTabBarOnPush:
            return "Hides tab bar on push"

        case .showNotificationIndicator:
            return "Shows notification indicator"
        }
    }

    var isOn: Bool {
        get {
            switch self {
            case let .hideTabBarOnPush(isOn), let .showNotificationIndicator(isOn):
                return isOn
            }
        }
        set {
            switch self {
            case .hideTabBarOnPush:
                self = .hideTabBarOnPush(isOn: newValue)

            case .showNotificationIndicator:
                self = .showNotificationIndicator(isOn: newValue)
            }
        }
    }
}
