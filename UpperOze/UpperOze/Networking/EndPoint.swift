import Foundation

protocol EndPointType {
    var baseURL: URL { get }
    var path: String? { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var task: HTTPTask { get }
}

enum HTTPMethod: String {
    case get            = "GET"
    case post           = "POST"
    case put            = "PUT"
    case patch          = "PATCH"
    case delete         = "DELETE"
}

typealias HTTPHeaders = [String : String]

enum HTTPTask {
    case request
    case requestParameters(bodyParametrs: Parameters?, urlParameters: Parameters?)
    case requestParametersAndHeaders(bodyParameters: Parameters?, urlParameters: Parameters?, additionHeaders: HTTPHeaders?)
}
