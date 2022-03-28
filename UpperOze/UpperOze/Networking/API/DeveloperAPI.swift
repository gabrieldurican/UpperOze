//
//  DeveloperAPI.swift
//  UpperOze
//
//  Created by gabriel durican on 3/26/22.
//

import Foundation

enum DeveloperAPI {
    case developer(login: String)
    case developerList(page: Int)
}

extension DeveloperAPI: EndPointType {
    var baseURL: URL {
        let url = URL(string: "https://api.github.com")!
        return url
    }
    
    var path: String? {
        switch self {
        case .developer(let login):
            return "/users/\(login)"
        case .developerList(_):
            return "/search/users"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var task: HTTPTask {
        switch self {
        case .developer(_):
            return .request
        case .developerList(let page):
            let params: Parameters = ["q" : "lagos", "page" : page]
            return .requestParameters(bodyParametrs: nil, urlParameters: params)
        }
    }
    
    
}

