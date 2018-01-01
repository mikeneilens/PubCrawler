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
        guard let viewControllers = self.viewControllers else {return}
        
        if appDelegate.crawlId.isNotEmpty {
            self.selectedIndex = 1
            showPubCrawlViewController(viewControllers:viewControllers, appDelegate:appDelegate)
        }
    }
    private func showPubCrawlViewController(viewControllers:[UIViewController], appDelegate:AppDelegate) {
        if viewControllers.count < 2 { return }
        guard let navController = viewControllers[1] as? UINavigationController else { return }

        navController.popToRootViewController(animated: false)
        if let pubCrawlsTVC = navController.viewControllers.first as? PubCrawlsTableViewController {
            pubCrawlsTVC.getPubCrawl(forCrawlId:appDelegate.crawlId)
            appDelegate.crawlId=""
        }
    }
}
