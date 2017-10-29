//
//  LabelViewExtensions.swift
//  pubCrawler
//
//  Created by Michael Neilens on 21/10/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit

extension UILabel {
    //determine whether the text within a label has been truncated due to lack of space.
    func isTruncated() -> Bool {
        
        if let string = self.text {
            let size: CGSize = (string as NSString).boundingRect(
                with: CGSize(width: self.frame.size.width, height: CGFloat(Float.greatestFiniteMagnitude)),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: [NSAttributedStringKey.font: self.font],
                context: nil).size
            
            return (size.height > self.bounds.size.height)
        }
        
        return false
    }
    
}
