//
//  ImageRepository.swift
//  UpperOze
//
//  Created by gabriel durican on 3/27/22.
//

import Foundation
import UIKit


class ImageRepository: Repository {
    typealias T = Data
    typealias D = Data
    typealias E = ImageAPI
    
    var router: Router<ImageAPI>
    var manager: NetworkManager
    let imageCache: NSCache<NSString, LocalImageData>
    
    required init(router: Router<ImageAPI> = Router(), manager: NetworkManager = NetworkManager()) {
        self.router = router
        self.manager = manager
        self.imageCache = NSCache<NSString, LocalImageData>()
    }
    
    func get(_ urlString: String, completion: @escaping (Data?, String?, String?) -> ()) -> Router<ImageAPI>? {
        guard urlString.count > 0 else {
            return nil
        }
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
            DispatchQueue.main.async {
                completion(imageFromCache.data, urlString, nil)
            }
            return nil
        }
        
        
        router.request(.image(urlString: urlString)) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            
            if error != nil {
                completion(nil, urlString, error?.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.manager.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, urlString, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    let dataObject = LocalImageData(data: responseData)
                    self.imageCache.setObject(dataObject, forKey: urlString as NSString)
                    completion(responseData, urlString,  nil)
                case .failure(let networkFailureError):
                    completion(nil, urlString, networkFailureError)
                }
            }
        }
        
        return router
    }
    
    func getListPage(_ page: Int, completion: @escaping (Data?, String?) -> ()) {
        //unneeded
    }
    
    func get(_ login: String, completion: @escaping (Data?, String?) -> ()) {
        //unneeded
    }
    
}
