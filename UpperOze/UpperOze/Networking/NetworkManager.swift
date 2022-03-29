import Foundation

struct NetworkManager {
    func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String> {
        switch response.statusCode {
        case 200...299:
            return .success
        case 401...500:
            return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599:
            return .failure(NetworkResponse.badRequest.rawValue)
        case 600:
            return .failure(NetworkResponse.outdated.rawValue)
        default:
            return .failure(NetworkResponse.failed.rawValue)
        }
    }
}

enum Result<String> {
    case success
    case failure(String)
}

enum NetworkResponse: String {
    case success
    case authenticationError = "Authentication error."
    case badRequest = "Bad request."
    case outdated = "The url you requested is outdated."
    case failed = "Nework request failed."
    case noData = "Response has no data."
    case unableToDecode = "Unable to decode the response."
}


