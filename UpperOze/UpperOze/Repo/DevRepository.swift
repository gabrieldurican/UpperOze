//
//  DevRepository.swift
//  UpperOze
//
//  Created by gabriel durican on 3/23/22.
//

import Foundation

class DevRepository: Repository {
    typealias T = Developer
    typealias D = DeveloperPage
    typealias E = DeveloperAPI
    
    var router: Router<DeveloperAPI>
    var manager: NetworkManager
    
    required init(router: Router<DeveloperAPI> = Router(), manager: NetworkManager = NetworkManager()) {
        self.router = router
        self.manager = manager
    }
    
    func get(_ login: String, completion: @escaping (Developer?, String?) -> ()) {
        router.request(.developer(login: login)) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            
            if error != nil {
                completion(nil, "Please check your internet connection.")
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
                        let apiResponse = try JSONDecoder.decode(DeveloperFull.self, from: responseData)
                        completion(apiResponse, nil)
                    } catch {
                        completion(nil, NetworkResponse.unabledToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func getListPage(_ page: Int, completion: @escaping (DeveloperPage?, String?) -> ()) {
        router.request(.developerList(page: page)) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            
            if error != nil {
                completion(nil, "Please check your internet connection.")
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
                        let apiResponse = try JSONDecoder().decode(DeveloperPage.self, from: responseData)
                        apiResponse.page = page
                        completion(apiResponse, nil)
                    } catch {
                        completion(nil, NetworkResponse.unabledToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    func get(_ urlString: String, completion: @escaping (Developer?, String?, String?) -> ()) -> Router<DeveloperAPI>? {
        //unneeded
        return nil
    }
}







