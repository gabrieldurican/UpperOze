//
//  URLParameterEncoder.swift
//  UpperOze
//
//  Created by gabriel durican on 3/26/22.
//

import Foundation

struct URLParameterEncoder: ParameterEncoder {
    public static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        guard let url = urlRequest.url else {
            throw NetworkError.urlNil
        }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), parameters.isEmpty == false {
            urlComponents.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                urlComponents.queryItems?.append(queryItem)
            }
            urlRequest.url = urlComponents.url
        }
        
        #warning("GABI check if needed")
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
//            urlRequest.setValue("charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
    }
}
