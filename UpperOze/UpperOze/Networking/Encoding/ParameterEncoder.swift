//
//  ParameterEncoder.swift
//  UpperOze
//
//  Created by gabriel durican on 3/26/22.
//

import Foundation

public typealias Parameters = [String : Any]

public protocol ParameterEncoder {
    static func encode(urlRequest: inout URLRequest,  with parameters: Parameters) throws
}

public enum NetworkError: String, Error {
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case urlNil = "URL is nil."
}
