//
//  HelpViewController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 12/03/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit
import WebKit

class HelpViewController: UIViewController {

    @IBOutlet weak var containerView: UIView? = nil
    var webView: WKWebView?
    
    override func loadView() {
        super.loadView()
        self.webView = WKWebView()
        self.view = self.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string:K.URL.helpURL) {
            let req = URLRequest(url:url)
            self.webView!.load(req)
            
        }
    }

}
