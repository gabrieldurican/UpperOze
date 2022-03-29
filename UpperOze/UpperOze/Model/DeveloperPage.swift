import Foundation
import RealmSwift

public final class DeveloperPage: Object, Decodable {
    @Persisted var page: Int
    @Persisted var totalCount: Int
    @Persisted var developers: List<Developer>

    private enum DeveloperPageCodingKeys: String, CodingKey {
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

        totalCount = try container.decode(Int.self, forKey: .totalCount)
        developers = try container.decode(List<Developer>.self, forKey: .developers)
    }
}
