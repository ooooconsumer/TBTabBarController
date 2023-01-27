//
//  ToggleTableViewCell.swift
//  SwiftExample
//
//  Created by Timur Ganiev on 09.12.2020.
//  Copyright © 2020-2023 Timur Ganiev. All rights reserved.
//

import UIKit

final class ToggleTableViewCell: UITableViewCell {

    // MARK: Private Properties

    private var switchControl: UISwitch? {
        accessoryView as? UISwitch
    }

    private var toggleHandler: ((Bool) -> Void)?

    // MARK: Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}

// MARK: Internal Methods

extension ToggleTableViewCell {
    
    func render(with item: ToggleItem, toggleHandler: @escaping (Bool) -> Void) {

        if #available(iOS 14.0, *) {
            var config = UIListContentConfiguration.subtitleCell()
            config.text = item.title
            contentConfiguration = config
        } else {
            textLabel?.text = item.title
        }

        switchControl?.setOn(item.isOn, animated: false)

        self.toggleHandler = toggleHandler
    }
}

// MARK: Private Methods

private extension ToggleTableViewCell {

    func setup() {
        let switchControl = UISwitch(frame: .zero)
        switchControl.addTarget(target, action: #selector(handleToggle), for: .valueChanged)
        accessoryView = switchControl
    }

    @objc
    func handleToggle() {
        toggleHandler?(switchControl?.isOn ?? false)
    }
}
