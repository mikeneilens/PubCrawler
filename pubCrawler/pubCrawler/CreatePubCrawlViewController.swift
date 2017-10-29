//
//  ViewController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 20/01/2017.
//  Copyright © 2017 Michael Neilens. All rights reserved.
//

import UIKit

class CreatePubCrawlViewController: AbstractViewController, UITextFieldDelegate, createPubCrawlDelegate {

    @IBOutlet weak var pubCrawlNameText: UITextField!
    var listOfPubCrawls:ListOfPubCrawls? //this contains the service that allows a pubCrawl to be created
    var pub:Pub?
    var delegate:createPubCrawlDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pubCrawlNameText.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField.text!.isEmpty  {
                self.showErrorMessage(withMessage: "Pub crawl name can't be blank", withTitle:"Invalid name")
                return false
            } else {
                textField.resignFirstResponder()
                self.addPubCrawl(withName: textField.text!)
                return true
            }
        
    }
    
    func addPubCrawl(withName name:String) {
        self.startActivityIndicator()

        if let pub = self.pub {
            PubCrawlCreator(withDelegate: .create(self), withPub:pub).create(name:name)
        } else
            if let listOfPubCrawls = self.listOfPubCrawls {
                PubCrawlCreator(withDelegate: .create(self)).create(forListOfPubCrawls:listOfPubCrawls, name:name)
        }
    }
    func finishedCreatingPubCrawl(listOfPubCrawls:ListOfPubCrawls, pub:Pub) {
        self.stopActivityIndicator()

        if listOfPubCrawls.isNotEmpty {
            NotificationCenter.default.post(changedListOfPubCrawls: listOfPubCrawls)
        }
        if pub.pubHeader.name.isNotEmpty {
            NotificationCenter.default.post(changedPub:pub)
        }
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
