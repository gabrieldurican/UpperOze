import Foundation
import UIKit
import RealmSwift


class BaseViewController: UIViewController {
    var realm: Realm?
    var notificationToken: NotificationToken?
    var devRepo = DevRepository()
    var imageRepo = ImageRepository()
    weak var coordinator: MainCoordinator?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureView()
        setupRealm()
    }
    
    
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .orange
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = .white
    }
    
    func configureView() {
        view.backgroundColor = UIColor.white
    }
    
    func setupRealm() {
        realm = try! Realm()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
}
