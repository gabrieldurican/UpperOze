//
//  Repository.swift
//  UpperOze
//
//  Created by gabriel durican on 3/23/22.
//

import Foundation

protocol Repository {
    associatedtype T
    associatedtype D
    associatedtype E: EndPointType
    
    var router: Router<E> { get set }
    var manager: NetworkManager { get set }
    
    func get(_ login: String, completion: @escaping (T?, String?) -> ())
    func get(_ urlString: String, completion: @escaping (T?, String?, String?) -> ()) -> Router<E>?
    func getListPage(_ page: Int, completion: @escaping (D?, String?) -> ())

    init(router: Router<E>, manager: NetworkManager)
}

