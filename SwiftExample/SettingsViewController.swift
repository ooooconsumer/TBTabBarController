//
//  SettingsViewController.swift
//  SwiftExample
//
//  Created by Timur Ganiev on 09.12.2020.
//  Copyright © 2020-2023 Timur Ganiev. All rights reserved.
//

import UIKit
import TBTabBarController

final class SettingsViewController: UITableViewController {

    // MARK: Private Properties

    private var items: [ToggleItem] = []
    private var isUpdatingTabBarPlacement = false

    // MARK: Lifecycle

    init() {
        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: NSStringFromClass(ToggleTableViewCell.self),
                for: indexPath
            ) as? ToggleTableViewCell
        else {
            return ToggleTableViewCell()
        }

        let item = items[indexPath.row]

        cell.render(with: item) { [weak self] isToggled in
            guard let self else { return }
            switch item {
            case .hideTabBarOnPush:
                self.setHideTabBarOnPush(isToggled)

            case .showNotificationIndicator:
                self.setShowsNotificationIndicator(isToggled)
            }
        }

        return cell
    }
}

// MARK: Private Methods

private extension SettingsViewController {

    func setup() {

        title = "Settings"

        items = [
            .hideTabBarOnPush(
                isOn: tb_hidesTabBarWhenPushed
            ),
            .showNotificationIndicator(
                isOn: navigationController?.tb_tabBarItem.showsNotificationIndicator ?? false
            )
        ]

        tableView.register(
            ToggleTableViewCell.self,
            forCellReuseIdentifier: NSStringFromClass(ToggleTableViewCell.self)
        )
    }

    func setHideTabBarOnPush(_ shouldHideBarWhenPushed: Bool) {
        
        if isUpdatingTabBarPlacement {
            items[0].isOn = shouldHideBarWhenPushed
            tableView.reloadData()
            return
        }
        
        isUpdatingTabBarPlacement.toggle()
        tb_hidesTabBarWhenPushed.toggle()
        
        UIView.animate(
            withDuration: 0.35,
            delay: .zero,
            options: UIView.AnimationOptions(rawValue: 7 << 16)
        ) {
            self.navigationController?.tb_tabBarController?.beginTabBarTransition()
        } completion: { _ in
            self.navigationController?.tb_tabBarController?.endTabBarTransition()
            self.isUpdatingTabBarPlacement.toggle()
        }
    }

    func setShowsNotificationIndicator(_ shouldShowNotificationIndicator: Bool) {
        navigationController?.tb_tabBarItem.showsNotificationIndicator = shouldShowNotificationIndicator
    }
}
