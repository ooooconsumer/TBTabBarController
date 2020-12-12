//
//  SceneDelegate.swift
//  SwiftExample
//
//  Created by Timur Ganiev on 09.12.2020.
//  Copyright © 2020 Timur Ganiev. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Public

    var window: UIWindow?
    
    // MARK: UIWindowSceneDelegate

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        EntryPoint.shared.setup(with: window!)
    }
}

