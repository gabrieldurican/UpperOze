//
//  Developer.swift
//  UpperOze
//
//  Created by gabriel durican on 3/23/22.
//

import Foundation
import RealmSwift

//struct Developer: Decodable {
//    let id: Int?
//    let name: String?
//    let avatarUrl: String?
//    let url: String?
//    let type: String?
//    let score: Double?
//    let isAdmin: Bool?
//
//    enum DeveloperCodingKeys: String, CodingKey {
//        case id
//        case name           = "login"
//        case avatarUrl      = "avatar_url"
//        case url
//        case type
//        case score
//        case isAdmin        = "site_admin"
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: DeveloperCodingKeys.self)
//
//        id = try container.decode(Int.self, forKey: .id)
//        name = try container.decode(String.self, forKey: .name)
//        avatarUrl = try container.decode(String.self, forKey: .avatarUrl)
//        url = try container.decode(String.self, forKey: .url)
//        type = try container.decode(String.self, forKey: .type)
//        score = try container.decode(Double.self, forKey: .score)
//        isAdmin = try container.decode(Bool.self, forKey: .isAdmin)
//    }
//}

class LocalImageData {
    var data: Data?
    
    init(data: Data?) {
        self.data = data
    }
}

public final class ImageData: Object {
//    @Persisted var data: Data?
    @Persisted var data: Data?
    @Persisted var index: Int?
    @Persisted var devName: String?
    
    public override class func primaryKey() -> String? {
        return "index"
    }

    convenience init (data: Data?, index: Int?, devName: String?) {
        self.init()
        self.data = data
        self.index = index
        self.devName = devName
    }
}



public final class Developer: Object, Decodable {
    @Persisted var id: Int?
    @Persisted var login: String?
    @Persisted var avatarUrl: String?
    @Persisted var url: String?
    @Persisted var type: String?
    @Persisted var score: Double?
    @Persisted var isAdmin: Bool?
    @Persisted var isFavorite: Bool = false
    
    enum DeveloperCodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl      = "avatar_url"
        case url
        case type
        case score
        case isAdmin        = "site_admin"
    }
    
    public override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(name: String?) {
        self.init()
    }
    
//    init(name: String) {
//        self.init()
//        self.name = name
//    }
    
    public convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: DeveloperCodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        login = try container.decode(String.self, forKey: .login).lowercased()
        avatarUrl = try container.decode(String.self, forKey: .avatarUrl)
        url = try container.decode(String.self, forKey: .url)
        type = try container.decode(String.self, forKey: .type)
        score = try container.decode(Double.self, forKey: .score)
        isAdmin = try container.decode(Bool.self, forKey: .isAdmin)
        isFavorite = false
    }
}


public final class DeveloperFull: Object, Decodable {
    @Persisted var id: Int?
    @Persisted var name: String?
    @Persisted var avatarUrl: String?
    @Persisted var url: String?
    @Persisted var type: String?
    @Persisted var company: String?
    @Persisted var blog: String?
    @Persisted var email: String?
    @Persisted var bio: String?
    @Persisted var hireable: Bool?
    
    enum DeveloperCodingKeys: String, CodingKey {
        case id
        case name
        case avatarUrl      = "avatar_url"
        case url
        case type
        case company
        case blog
        case email
        case bio
        case hireable
    }
    
    public override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(name: String?) {
        self.init()
    }
    
//    init(name: String) {
//        self.init()
//        self.name = name
//    }
    
    public convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: DeveloperCodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name).lowercased()
        avatarUrl = try container.decode(String.self, forKey: .avatarUrl)
        url = try container.decode(String.self, forKey: .url)
        company = try container.decode(String.self, forKey: .company)
        blog = try container.decode(String.self, forKey: .blog)
        email = try container.decode(String.self, forKey: .email)
        bio = try container.decode(String.self, forKey: .bio)
        hireable = try container.decode(Bool.self, forKey: .hireable)
    }
}
