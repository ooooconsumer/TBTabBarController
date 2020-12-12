//
//  ToggleTableViewCell.swift
//  SwiftExample
//
//  Created by Timur Ganiev on 09.12.2020.
//  Copyright © 2020 Timur Ganiev. All rights reserved.
//

import UIKit

class ToggleTableViewCell: UITableViewCell {
    
    // MARK: - Public
    
    // MARK: Lifecycle
    
    init(with text: String, enabled: Bool) {
        super.init(style: .default, reuseIdentifier: nil)
        _configure(with: text, enabled: enabled)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Interface
    
    func addTarget(target: Any, action: Selector) {
        
        guard let switchView = accessoryView as? UISwitch else {
            return
        }
        
        switchView.addTarget(target, action: action, for: .valueChanged)
    }

    // MARK: - Private
    
    // MARK: Setup
    
    fileprivate func _configure(with text:String, enabled: Bool) {
        
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(enabled, animated: false)
        
        accessoryView = switchView
        
        if #available(iOS 14.0, *) {
            var config = UIListContentConfiguration.subtitleCell()
            config.text = text
            contentConfiguration = config
        } else {
            textLabel?.text = text
        }
    }
}
