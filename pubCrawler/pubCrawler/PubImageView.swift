//
//  PubImageView.swift
//  pubCrawler
//
//  Created by Michael Neilens on 03/03/2017.
//  Copyright © 2017 Michael Neilens. All rights reserved.
//

import UIKit

enum ImageStatus {
    case noPubImage
    case imageNotLoaded
    case imageLoaded
}
var imageCache = NSCache<AnyObject, AnyObject>() //force any images to be cached

protocol PubImageLoadedDelegate {
    func pubImageLoaded(imageStatus:ImageStatus)
}

class PubImageView: UIImageView {

    private var delegate:PubImageLoadedDelegate?
    
    private func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            
            imageCache.setObject(data as AnyObject, forKey:url  as AnyObject)
            DispatchQueue.main.async() { () -> Void in
                self.image = image
                if let delegate = self.delegate {
                    delegate.pubImageLoaded(imageStatus:self.typeOfImage(imageData:data ))
                }
            }
            }.resume()
    }
    func downloadedFrom(link: String, delegate:PubImageLoadedDelegate?, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        self.delegate = delegate
        
        if let imageData = imageCache.object(forKey:url as AnyObject) {
            let image = UIImage(data:imageData as! Data)
            DispatchQueue.main.async() { () -> Void in
                self.image = image
                if let delegate = self.delegate {
                    delegate.pubImageLoaded(imageStatus:self.typeOfImage(imageData: imageData as! Data))
                }
            }
        } else {
            self.delegate = delegate
            downloadedFrom(url: url, contentMode: mode)
        }
    }
    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        self.downloadedFrom(link: link, delegate:nil, contentMode:mode)
    }
    
    private func typeOfImage (imageData:Data) -> ImageStatus {
        if imageData.count == 20409 {
            return ImageStatus.noPubImage
        } else {
            return ImageStatus.imageLoaded
        }
    }
}
