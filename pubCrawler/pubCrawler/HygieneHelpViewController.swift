//
//  HygieneHelpViewController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 30/10/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit
import WebKit

class HygieneHelpViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView? = nil
    var webView: WKWebView?
    
    override func loadView() {
        super.loadView()
        self.webView = WKWebView()
        self.view = self.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string:K.URL.hygieneHelpURL) {
            let req = URLRequest(url:url)
            self.webView!.load(req)
            
        }
    }
    
}
