import Foundation
import RealmSwift

protocol Repository {
    associatedtype D: RealmCollectionValue
    associatedtype E: EndPointType
    
    func get(_ login: String, realm: Realm, completion: @escaping (D?, String?) -> ())
    func getData(_ urlString: String, linkedId: String, realm: Realm, completion: @escaping (Data?, String?, String?) -> ()) -> Router<E>?
    func getAllForPage(_ page: Int, realm: Realm, completion: @escaping (List<D>?, String?) -> ())
}

