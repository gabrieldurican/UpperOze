import Foundation
import RealmSwift



public final class Developer: Object, Decodable {
    @Persisted var id: Int?
    @Persisted var login: String?
    @Persisted var avatarUrl: String?
    @Persisted var url: String?
    @Persisted var type: String?
    @Persisted var score: Double?
    @Persisted var isAdmin: Bool?
    @Persisted var name: String?
    @Persisted var location: String?
    @Persisted var company: String?
    @Persisted var blog: String?
    @Persisted var email: String?
    @Persisted var bio: String?
    @Persisted var hireable: Bool?
    @Persisted var isFavorite: Bool = false

    enum DeveloperCodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl      = "avatar_url"
        case url
        case type
        case score
        case isAdmin        = "site_admin"
        case name
        case company
        case blog
        case email
        case bio
        case hireable
        case location
    }

    public override class func primaryKey() -> String? {
        return "login"
    }

    convenience init(name: String?) {
        self.init()
    }

    public convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: DeveloperCodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        login = try container.decodeIfPresent(String.self, forKey: .login)?.lowercased()
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        score = try container.decodeIfPresent(Double.self, forKey: .score)
        isAdmin = try container.decodeIfPresent(Bool.self, forKey: .isAdmin)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        company = try container.decodeIfPresent(String.self, forKey: .company)
        blog = try container.decodeIfPresent(String.self, forKey: .blog)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        hireable = try container.decodeIfPresent(Bool.self, forKey: .hireable)
        location = try container.decodeIfPresent(String.self, forKey: .location)
    }
}
