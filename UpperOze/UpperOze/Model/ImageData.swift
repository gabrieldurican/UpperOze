import Foundation
import RealmSwift

public final class ImageData: Object {
    @Persisted var data: Data?
    @Persisted var devLogin: String?
    
    public override class func primaryKey() -> String? {
        return "devLogin"
    }
    
    convenience init (data: Data?, devLogin: String?) {
        self.init()
        self.data = data
        self.devLogin = devLogin
    }
}

class LocalImageData {
    var data: Data?
    
    init(data: Data?) {
        self.data = data
    }
}
