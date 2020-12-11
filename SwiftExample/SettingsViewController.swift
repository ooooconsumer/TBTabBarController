//
//  SettingsViewController.swift
//  SwiftExample
//
//  Created by Timur Ganiev on 09.12.2020.
//  Copyright © 2020 Timur Ganiev. All rights reserved.
//

import UIKit
import TBTabBarController

class SettingsViewController: UITableViewController {

    // MARK: - Public
    
    // MARK: Lifecycle
    
    init() {
        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Overrides

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = "Settings"
        
        let hidesTabBarOnPushSettingCell = ToggleTableViewCell(with: "Hides tab bar on push", enabled: tb_hidesTabBarWhenPushed)
        hidesTabBarOnPushSettingCell.addTarget(target: self, action: #selector(_setHideTabBarOnPush(sender:)))
        
        let showsNotificationIndicatorCell = ToggleTableViewCell(with: "Shows notification indicator", enabled: (navigationController?.tb_tabBarItem.showsNotificationIndicator)!)
        showsNotificationIndicatorCell.addTarget(target: self, action: #selector(_setShowsNotificationIndicator))
        
        _cells = [hidesTabBarOnPushSettingCell, showsNotificationIndicatorCell]
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return _cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return _cells[indexPath.row]
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Private
    
    fileprivate var _cells: [UITableViewCell]!
    
    fileprivate var _isUpdatingTabBarPosition = false
    
    // MARK: Actions
    
    @objc fileprivate func _setHideTabBarOnPush(sender: UISwitch) {
        
        if _isUpdatingTabBarPosition {
            sender.setOn(!sender.isOn, animated: true)
            return
        }
        
        _isUpdatingTabBarPosition.toggle()
        
        tb_hidesTabBarWhenPushed.toggle()
        
        UIView.animate(withDuration: 0.35, delay: 0.0, options: UIView.AnimationOptions(rawValue: 7 << 16)) {
            self.navigationController?.tb_tabBarController?.beginUpdateTabBarPosition()
        } completion: { (finished) in
            self.navigationController?.tb_tabBarController?.endUpdateTabBarPosition()
            self._isUpdatingTabBarPosition.toggle()
        }
    }

    @objc fileprivate func _setShowsNotificationIndicator() {
        
        navigationController?.tb_tabBarItem.showsNotificationIndicator.toggle()
    }
}
