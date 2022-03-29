import Foundation
import RealmSwift

class DevRepository: Repository {
    typealias E = DeveloperAPI
    typealias D = Developer
    
    var router = Router<DeveloperAPI>()
    var manager = NetworkManager()
       
    func get(_ login: String, realm: Realm, completion: @escaping (Developer?, String?) -> ()) {
        router.request(.developer(login: login)) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            
            if error != nil {
                completion(nil, error?.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.manager.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    do {
                        let devFull = try JSONDecoder().decode(Developer.self, from: responseData)
                        
                        DispatchQueue.main.async {
                            try! realm.write({
                                realm.add(devFull, update: .all)
                            })
                            completion(devFull, nil)
                        }
                    } catch {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }

    
    func getAllForPage(_ page: Int, realm: Realm, completion: @escaping (List<Developer>?, String?) -> ()) {
        router.request(.developerList(page: page)) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            
            if error != nil {
                completion(nil, error?.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.manager.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    do {
                        let devPage = try JSONDecoder().decode(DeveloperPage.self, from: responseData)
                        DispatchQueue.main.async {
                            try! realm.write({
                                devPage.developers.forEach {
                                    realm.add($0, update: .all)
                                }
                            })
                            completion(devPage.developers, nil)
                        }
                        
                    } catch {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getData(_ urlString: String, linkedId: String, realm: Realm, completion: @escaping (Data?, String?, String?) -> ()) -> Router<DeveloperAPI>? {
        //unneeded
        return nil
    }
}







