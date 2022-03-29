import Foundation

enum ImageAPI {
    case image(urlString: String)
}

extension ImageAPI: EndPointType {
    var baseURL: URL {
        switch self {
        case .image(let urlString):
            guard let url = URL(string: urlString) else {
                return URL(string: "")!
            }
            
            return url
        }
    }
    
    var path: String? {
        return nil
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var task: HTTPTask {
        return .request
    }
    
    
}
