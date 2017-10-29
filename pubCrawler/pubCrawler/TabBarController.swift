//
//  TabBarController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 22/07/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(switchToPubCrawls),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
    }
 
    @objc func switchToPubCrawls() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        if appDelegate.crawlId.isNotEmpty {
            self.selectedIndex = 1
            let navController = self.viewControllers![1] as! UINavigationController
            navController.popToRootViewController(animated: false)
            
            if let pubCrawlsTVC = navController.viewControllers.first as? PubCrawlsTableViewController {
                pubCrawlsTVC.getPubCrawl(forCrawlId:appDelegate.crawlId)
                appDelegate.crawlId=""
            }
        }
    }
}
