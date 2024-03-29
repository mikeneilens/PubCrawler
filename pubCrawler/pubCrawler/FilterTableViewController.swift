//
//  OptionsTableViewController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 02/03/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit

class FilterTableViewController: UITableViewController, SettingsSwitchDelegate {

    var options=[SearchTerm]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getSearchOptions()
                
        let pubCrawlnib = UINib(nibName: "SettingsTableViewCell", bundle: nil)
        tableView.register(pubCrawlnib, forCellReuseIdentifier: "SettingsTableViewCell")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.options.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as! SettingsTableViewCell
        return configureSettingsCell(cell, searchTerm: self.options[indexPath.row])
    }
    
    func configureSettingsCell(_ settingsCell:SettingsTableViewCell, searchTerm: SearchTerm ) ->SettingsTableViewCell {
        settingsCell.labelText.text = searchTerm.text
        settingsCell.label = searchTerm.text
        settingsCell.delegate = self
        settingsCell.optionSwitch.isOn = searchTerm.value
        return settingsCell
    }
    
    func settingsSwitchChanged(optionSwitch: UISwitch, label:String) {
        for (i, searchTerm) in self.options.enumerated() {
            let indexPath=IndexPath(row: i, section: 0)
            let cell = self.tableView.cellForRow(at: indexPath) as! SettingsTableViewCell
            let newSearchTerm = searchTerm.update(value: cell.optionSwitch.isOn)
            newSearchTerm.write()
        }
        
        let nc = NotificationCenter.default
        nc.post(name:K.Notification.filterChanged, object: nil, userInfo: nil)
    }
    
    func getSearchOptions() {
        self.options = UId().searchOptions
    }
}
