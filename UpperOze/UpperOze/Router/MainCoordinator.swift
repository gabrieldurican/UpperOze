import Foundation
import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = DeveloperListViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func showFavorites() {
        let fav = FavoritesViewController()
        fav.coordinator = self
        navigationController.pushViewController(fav, animated: true)
    }
    
    func showDeveloperDetails(devLogin: String?, imageUrl: String?) {
        let devVC = DeveloperViewController(devLogin: devLogin ?? "", imageUrl: imageUrl ?? "")
        devVC.coordinator = self
        navigationController.pushViewController(devVC, animated: true)
    }
}
