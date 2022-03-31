import UIKit
import RealmSwift

class DeveloperListViewController: BaseViewController {
    var developers: Results<Developer>?
    var imageNotificationToken: NotificationToken?
    var tableView = UITableView()
    
    var limitIndex: Int = 0
    var currentPage: Int = 1
    var offset: Int = 5
    var maxPage = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        startObservingRealm()
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        tableView.fixInView(view)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DeveloperListCell.self, forCellReuseIdentifier: DeveloperListCell.kCellId)
        tableView.backgroundColor = UIColor.white
        self.tableView.contentInsetAdjustmentBehavior = .always
    }
    
    override func configureNavigationBar() {
        super.configureNavigationBar()
        title = "Developers"
        let favoritesBarButton = UIBarButtonItem(image: UIImage.init(named: "multipleStars"), style: .done, target: self, action: #selector(goToFavorites))
        favoritesBarButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = favoritesBarButton
    }
    
    func startObservingRealm() {
        developers = realm?.objects(Developer.self).sorted(byKeyPath: "login")
        notificationToken = developers?.observe { [weak self] changes in
            guard let self = self else {
                return
            }
            
            switch changes {
            case .initial:
                self.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self.tableView.performBatchUpdates({
                    self.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }),
                                              with: .automatic)
                    self.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                              with: .automatic)
                    self.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                              with: .automatic)
                })
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getDevelopersForPage(page: currentPage)
    }
        
    func getDevelopersForPage(page: Int) {
        guard let realm = realm else{
            return
        }
        
        devRepo.getAllForPage(page, realm: realm, completion: { developers, error in
            DispatchQueue.main.async {
                self.limitIndex = (self.developers?.count ?? 0) - self.offset
            }
            
        })
    }

    @objc func goToFavorites() {
        coordinator?.showFavorites()
    }
}

extension DeveloperListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return developers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DeveloperListCell.kCellId) as? DeveloperListCell
        
        guard let dev = developers?[indexPath.row], let realm = realm else {
            return UITableViewCell()
        }
        
        cell?.configure(developer: dev, repo: imageRepo, realm: realm)
        cell?.delegate = self
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let dev = developers?[indexPath.row] else {
            return
        }
        
        coordinator?.showDeveloperDetails(devLogin: dev.login, imageUrl: dev.avatarUrl)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard limitIndex > 0 else {
            return
        }
        
        if indexPath.row == limitIndex {
            //needs new page download
            currentPage = min(currentPage + 1, maxPage)
            
            getDevelopersForPage(page: currentPage)
        }
    }
    
}

extension DeveloperListViewController: DeveloperListCellDelegate {
    func tappedFavorite(cell: DeveloperListCell) {
        guard let index = self.tableView.indexPath(for: cell),
              let dev = developers?[index.row],
              index.row < (developers?.count ?? 0) else {
            return
        }
        
        guard let realmDev = realm?.object(ofType: Developer.self, forPrimaryKey: dev.login) else {
            return
        }
        
        try! realm?.write({
            realmDev.isFavorite = !realmDev.isFavorite
            realm?.add(realmDev, update: .all)
        })
    }
}

