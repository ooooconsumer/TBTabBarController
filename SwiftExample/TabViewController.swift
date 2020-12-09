//
//  TabViewController.swift
//  SwiftExample
//
//  Created by Timur Ganiev on 09.12.2020.
//  Copyright © 2020 Timur Ganiev. All rights reserved.
//

import UIKit
import TBTabBarController

class TabViewController: UITableViewController {
    
    // MARK: - Public
    
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
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = UISearchController(searchResultsController: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        navigationController?.tb_tabBarItem.showsNotificationIndicator = false;
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        
        let title = "Cell at index \(indexPath.row)"
        let subtitle = "Tap to show settings"
        
        if #available(iOS 14.0, *) {
            var config = UIListContentConfiguration.subtitleCell()
            config.text = title
            config.secondaryText = subtitle
            cell?.contentConfiguration  = config
        } else {
            cell?.textLabel?.text = title
            cell?.detailTextLabel?.text = subtitle
        }
        
        cell?.accessoryType = .disclosureIndicator
        
        return cell!
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        navigationController?.pushViewController(SettingsViewController(), animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50.0
    }
}

