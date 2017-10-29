//
//  AbstractTableViewController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 02/03/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit
import MNWebServiceCall

protocol CallWebServiceType {
    func requestFailed(error:JSONError, errorText:String, errorTitle:String)
}

class AbstractTableViewController: UITableViewController {

    private var activities = 0
    private var rightButtonState=false
    private var activityView = UIActivityIndicatorView()
    
    func startActivityIndicator()  {
        self.tableView.addSubview(activityView)
        activityView.activityIndicatorViewStyle = .whiteLarge
        activityView.hidesWhenStopped = true;

    // Center
        let viewFrame=self.view.frame
        let x = viewFrame.size.width/2 //UIScreen.mainScreen.applicationFrame.size.width/2;
        let y = UIScreen.main.bounds.size.height/2;
    // Offset. If tableView has been scrolled
        let yOffset = self.tableView.contentOffset.y
        activityView.frame = CGRect(x: x, y: y + yOffset, width: 0, height: 0)
        activityView.color = UIColor.black
    
        activityView.isHidden = false
        activityView.startAnimating()
    
        activities += 1;

        self.removeRightButton()
        self.disableView()
    }
    func stopActivityIndicator(withMessage message:String, withTitle:String) {
        self.stopActivityIndicator()
        self.showErrorMessage(withMessage:message, withTitle:withTitle)
    }
    
    func stopActivityIndicator()  {
        if self.activities > 0 {
            self.activities=self.activities-1
        }
        
        if self.activities == 0 {
            self.activityView.stopAnimating()
            self.enableView()
            self.reinstateRightButton()
        }
    }
    
    func showErrorMessage(withMessage message:String, withTitle:String) {
        let alert = UIAlertController(title: withTitle, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }

    func requestFailed(error:JSONError, errorText:String, errorTitle:String) {
        self.stopActivityIndicator(withMessage:errorText, withTitle:errorTitle)
    }
    
    private func disableView(){
        self.view.isUserInteractionEnabled = false
        if let navController = self.navigationController{
            navController.navigationBar.isUserInteractionEnabled=false
        }

    }
    private func enableView() {
        self.view.isUserInteractionEnabled = true
        if let navController=self.navigationController {
            navController.navigationBar.isUserInteractionEnabled=true
        }
    }
    private func removeRightButton() {
        if let rightButton = self.navigationItem.rightBarButtonItem {
            rightButtonState = rightButton.isEnabled
            rightButton.isEnabled = false
        } else {
            rightButtonState = true
        }
    }
    private func reinstateRightButton() {
        if let rightButton = self.navigationItem.rightBarButtonItem {
            rightButton.isEnabled = rightButtonState
        }
    }
}