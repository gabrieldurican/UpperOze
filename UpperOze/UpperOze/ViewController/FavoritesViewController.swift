import Foundation
import UIKit
import RealmSwift

class FavoritesViewController: BaseViewController {
    let tableView = UITableView()
    var developers: Results<Developer>?
    let noFavoritesLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(DeveloperListCell.self, forCellReuseIdentifier: DeveloperListCell.kCellId)
        setupUI()
        addClearAllButton()
        self.title = "Favorites"
        
        startObservingRealm()
    }

    func startObservingRealm() {
        developers = realm?.objects(Developer.self).filter("isFavorite == true")
        handleCurrentState()
        notificationToken = developers?.observe { [weak self] changes in
            guard let self = self else {
                return
            }
            
            self.handleCurrentState()
            
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

    func addClearAllButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear all", style: .plain, target: self, action: #selector(clearAllTapped))
    }
    
    func handleCurrentState() {
        let noFav = developers?.count == 0
        noFavoritesLabel.isHidden = !noFav
        tableView.isHidden = noFav
        if noFav {
            navigationItem.rightBarButtonItem = nil
        } else {
            addClearAllButton()
        }
    }
    
    
    func setupUI() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.fixInView(view)
        view.addSubview(noFavoritesLabel)
        noFavoritesLabel.textColor = .black
        noFavoritesLabel.font = UIFont.systemFont(ofSize: 20)
        noFavoritesLabel.text = "You have no favorites."
        adjustFavoritesLabelConstraints()
    }
    
    func adjustFavoritesLabelConstraints() {
        noFavoritesLabel.translatesAutoresizingMaskIntoConstraints = false
        noFavoritesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noFavoritesLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc func clearAllTapped() {
        try! realm?.write({
            developers?.forEach {
                $0.isFavorite = !$0.isFavorite
                realm?.add($0, update: .all)
            }
        })
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
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
        
        cell?.configure(developer: dev, repo: imageRepo, realm: realm, showFavorite: false)
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let dev = developers?[indexPath.row], let realmDev = realm?.object(ofType: Developer.self, forPrimaryKey: dev.login) else {
                return
            }
            
            try! realm?.write({
                realmDev.isFavorite = !realmDev.isFavorite
                realm?.add(realmDev, update: .all)
            })
        }
    }
    
}
