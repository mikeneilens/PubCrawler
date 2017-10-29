//
//  OptionsTableViewController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 02/03/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, SettingsSwitchDelegate {

    let pubOptionHeading = "Only find pubs"
    let realAleOptionHeading = "Only find pubs selling real ale"
    let memberDiscountHeading = "Discount scheme"
    var headings=[String]()

    var options=[SearchOption]()   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.headings=[self.pubOptionHeading, self.realAleOptionHeading, self.memberDiscountHeading]
        let pubCrawlnib = UINib(nibName: "SettingsTableViewCell", bundle: nil)
        tableView.register(pubCrawlnib, forCellReuseIdentifier: "SettingsTableViewCell")

        self.getSearchOptions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.headings.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = UITableViewCell()
        
        switch self.headings[row] {
        case  self.pubOptionHeading:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as! SettingsTableViewCell
            cell.labelText.text = self.pubOptionHeading
            cell.label = self.pubOptionHeading
            cell.delegate = self
            cell.optionSwitch.isOn = self.optionsInclude(searchOption: SearchOption.pubs)
            
            return cell
        case self.realAleOptionHeading:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as! SettingsTableViewCell
            cell.labelText.text = self.realAleOptionHeading
            cell.label = self.realAleOptionHeading
            cell.delegate = self
            cell.optionSwitch.isOn=self.optionsInclude(searchOption: SearchOption.realAle)
            
            return cell
        case self.memberDiscountHeading:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as! SettingsTableViewCell
            cell.labelText.text = self.memberDiscountHeading
            cell.label = self.memberDiscountHeading
            cell.delegate = self
            cell.optionSwitch.isOn=self.optionsInclude(searchOption: SearchOption.memberDiscountScheme)
            
            return cell

        default:
            break
        }

        return cell
    }
    
    func optionsInclude(searchOption:SearchOption) -> Bool {
        for option in self.options {
            if option == searchOption  {
                return true
            }
        }
        return false
    }
    
    func settingsSwitchChanged(optionSwitch: UISwitch, label:String) {
        self.options=[SearchOption]()
        for i in 0..<headings.count {
            let indexPath=IndexPath(row: i, section: 0)
            let cell = self.tableView.cellForRow(at: indexPath) as! SettingsTableViewCell
            
            switch cell.label {
                case self.pubOptionHeading:
                    if (cell.optionSwitch.isOn == true) {
                        self.options.append(SearchOption.pubs)
                    }
                case self.realAleOptionHeading:
                    if (cell.optionSwitch.isOn == true) {
                        self.options.append(SearchOption.realAle)
                    }
                case self.memberDiscountHeading:
                    if (cell.optionSwitch.isOn == true) {
                        self.options.append(SearchOption.memberDiscountScheme)
                    }
                default:
                    break
            }
        }
        self.saveSearchOptions()
    }
    
    func getSearchOptions() {
        self.options=[SearchOption]()
        let defaults: UserDefaults = UserDefaults.standard
        if  defaults.bool(forKey: K.DefaultKey.SearchOption.onlyPubs)  {
            self.options.append(SearchOption.pubs)
        }
        if defaults.bool(forKey: K.DefaultKey.SearchOption.onlyRealAle)  {
            self.options.append(SearchOption.realAle)
        }
        if defaults.bool(forKey: K.DefaultKey.SearchOption.onlyMembersDiscount)  {
            self.options.append(SearchOption.memberDiscountScheme)
        }
    }
    
    func saveSearchOptions() {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(false, forKey: K.DefaultKey.SearchOption.onlyPubs)
        defaults.set(false, forKey: K.DefaultKey.SearchOption.onlyRealAle)
        defaults.set(false, forKey: K.DefaultKey.SearchOption.onlyMembersDiscount)
        
        for option in self.options {
            switch option {
            case .pubs:
                defaults.set(true, forKey: K.DefaultKey.SearchOption.onlyPubs)
            case .realAle:
                defaults.set(true, forKey: K.DefaultKey.SearchOption.onlyRealAle)
            case .memberDiscountScheme:
                defaults.set(true, forKey: K.DefaultKey.SearchOption.onlyMembersDiscount)
            }
        }
    }

}
