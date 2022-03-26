//
//  Developer.swift
//  UpperOze
//
//  Created by gabriel durican on 3/23/22.
//

import Foundation
struct Developer: Decodable {
    let id: String?
    let name: String?
    let avatarUrl: String?
    let url: String?
    let type: String?
    let score: Double?
    let isAdmin: Bool?
    
    enum DeveloperCodingKeys: String, CodingKey {
        case id
        case name
        case avatarUrl      = "avatar_url"
        case url
        case type
        case score
        case isAdmin        = "site_admin"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DeveloperCodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        avatarUrl = try container.decode(String.self, forKey: .avatarUrl)
        url = try container.decode(String.self, forKey: .url)
        type = try container.decode(String.self, forKey: .type)
        score = try container.decode(Double.self, forKey: .score)
        isAdmin = try container.decode(Bool.self, forKey: .isAdmin)
    }
}
