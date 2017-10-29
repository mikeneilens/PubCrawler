//
//  PictureViewController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 26/02/2017.
//  Copyright © 2017 Michael Neilens. All rights reserved.
//

import UIKit

class PictureViewController: UIViewController {

    @IBOutlet weak var image: PubImageView!
    var photoURL=""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.image.downloadedFrom(link:photoURL)
    }

}
