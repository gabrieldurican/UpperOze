//
//  Repository.swift
//  UpperOze
//
//  Created by gabriel durican on 3/23/22.
//

import Foundation

protocol Repository {
    associatedtype T
    
    func get(_ id: Int) -> T?
    func getListPage(_ page: Int) -> [T]
}
