//
//  DeveloperList.swift
//  UpperOze
//
//  Created by gabriel durican on 3/26/22.
//

import Foundation
import RealmSwift

//struct DeveloperPage: Decodable {
////    let page: Int
//    let totalCount: Int
//    let developers: [Developer]
//
//    private enum DeveloperPageCodingKeys: String, CodingKey {
////        case page
//        case totalCount         = "total_count"
//        case developers         = "items"
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: DeveloperPageCodingKeys.self)
//
////        page = try container.decode(Int.self, forKey: .page)
//        totalCount = try container.decode(Int.self, forKey: .totalCount)
//        developers = try container.decode([Developer].self, forKey: .developers).sorted(by: {
//            ($0.name?.lowercased() ?? "") < ($1.name?.lowercased() ?? "")
//        })
//    }
//}

public final class DeveloperPage: Object, Decodable {
    @Persisted var page: Int
    @Persisted var totalCount: Int
    @Persisted var developers: List<Developer>

    private enum DeveloperPageCodingKeys: String, CodingKey {
//        case page
        case totalCount         = "total_count"
        case developers         = "items"
    }
    
    public override class func primaryKey() -> String? {
        return "page"
    }
    
    convenience init(developers: List<Developer>?) {
        self.init()
    }

    public convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: DeveloperPageCodingKeys.self)

        //        page = try container.decode(Int.self, forKey: .page)
        totalCount = try container.decode(Int.self, forKey: .totalCount)
        developers = try container.decode(List<Developer>.self, forKey: .developers)
//        try container.decode(List<Developer>.self, forKey: .developers).sorted(by: {
//            ($0.name?.lowercased() ?? "") < ($1.name?.lowercased() ?? "")
//        })
    }
}
