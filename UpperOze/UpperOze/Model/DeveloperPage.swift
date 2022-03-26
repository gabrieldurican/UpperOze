//
//  DeveloperList.swift
//  UpperOze
//
//  Created by gabriel durican on 3/26/22.
//

import Foundation

struct DeveloperPage: Decodable {
    let page: Int
    let totalCount: Int
    let developers: [Developer]
    
    private enum DeveloperPageCodingKeys: String, CodingKey {
        case page
        case totalCount         = "total_count"
        case developers         = "items"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DeveloperPageCodingKeys.self)
        
        page = try container.decode(Int.self, forKey: .page)
        totalCount = try container.decode(Int.self, forKey: .totalCount)
        developers = try container.decode([Developer].self, forKey: .developers)
    }
}
