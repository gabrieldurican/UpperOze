import Foundation
import UIKit
import RealmSwift

class ImageRepository: Repository {
    
    
    typealias E = ImageAPI
    
    var router = Router<ImageAPI>()
    var manager = NetworkManager()
    let imageCache = NSCache<NSString, LocalImageData>()
    
    @discardableResult func getData(_ urlString: String, linkedId: String, realm: Realm, completion: @escaping (Data?, String?, String?) -> ()) -> Router<ImageAPI>? {
        guard urlString.count > 0 else {
            return nil
        }
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
            DispatchQueue.main.async {
                completion(imageFromCache.data, urlString, nil)
            }
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
                    
                    //cache the image
                    let dataObject = LocalImageData(data: responseData)
                    self.imageCache.setObject(dataObject, forKey: urlString as NSString)
                    
                    DispatchQueue.main.async {
                        try! realm.write({
                            let image = ImageData(data: responseData, devLogin: linkedId)
                            
                            realm.add(image, update: .all)
                        })
                    }
                    completion(responseData, urlString,  nil)
                    
                case .failure(let networkFailureError):
                    completion(nil, urlString, networkFailureError)
                }
            }
        }
        
        return router
    }
    func get(_ login: String, realm: Realm, completion: @escaping (Data?, String?) -> ()) {
        //unneeded
    }
        
    func getAllForPage(_ page: Int, realm: Realm, completion: @escaping (List<Data>?, String?) -> ()) {
        //unneeded
    }
    
}
