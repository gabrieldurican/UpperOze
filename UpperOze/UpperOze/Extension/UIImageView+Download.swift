//
//  UIImageView+Download.swift
//  UpperOze
//
//  Created by gabriel durican on 3/27/22.
//

import Foundation
import UIKit

//let imageCache = NSCache<AnyObject, AnyObject>()
//
//extension UIImageView {
//    func loadThumbnail(urlString: String, repo: ImageRepository? = ImageRepository(router: Router(), manager: NetworkManager())) {
//        guard urlString.count > 0 else {
//            return
//        }
//        
//        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) {
//            DispatchQueue.main.async {
//                self.image = imageFromCache as? UIImage
//            }
//            return
//        }
//        
//        repo?.get(urlString, completion: { [weak self] data, error in
//            guard let self = self, let data = data else {
//                return
//            }
//            
//            if error == nil {
//                guard let imageToCache = UIImage(data: data) else {
//                    return
//                }
//                
//                imageCache.setObject(imageToCache, forKey: urlString as AnyObject)
//                DispatchQueue.main.async {
//                    self.image = imageToCache
//                }
//                
//            }
//        })
//        
//            
//    }
//}
