//
//  FavoritesViewController.swift
//  UpperOze
//
//  Created by gabriel durican on 3/28/22.
//

import Foundation
import UIKit
import RealmSwift

class FavoritesViewController: UITableViewController {
    var realm: Realm
//    let tableView = UITableView()
    var developers: Results<Developer>
    var notificationToken: NotificationToken?
    var repository: DevRepository?
    var imageRepo: ImageRepository?
    
//    init(realm: Realm) {
//        self.realm = realm
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    init(userRealmConfiguration: Realm.Configuration) {
        self.realm = try! Realm(configuration: userRealmConfiguration)
        developers = realm.objects(Developer.self).filter("isFavorite == true")
//        images = realm.objects(ImageData.self).sorted(byKeyPath: "index")
        
        super.init(nibName: nil, bundle: nil)
        
        notificationToken = developers.observe { [weak self] changes in
            guard let self = self else {
                return
            }
            
            switch changes {
            case .initial:
                self.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self.tableView.performBatchUpdates({
                    print("UPDATING")
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        repository = DevRepository()
        imageRepo = ImageRepository()
        view.backgroundColor = UIColor.orange
        configureNavigationBar()
        tableView.register(DeveloperListCell.self, forCellReuseIdentifier: DeveloperListCell.kCellId)
        setupUI()
        
        startObservingRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateDevelopers()
    }
    
    func updateDevelopers() {
        developers = realm.objects(Developer.self).filter("isFavorite == true")
    }
    
    func startObservingRealm() {
        notificationToken = developers.observe { [weak self] changes in
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
    #warning("GABI check if the two controllers can be superclassed")
    
    deinit {
        notificationToken?.invalidate()
    }
    
    func configureNavigationBar() {
        self.title = "Favorite developers"
        let clearBarButton = UIBarButtonItem(title: "Clear all", style: .plain, target: self, action: #selector(clearAllTapped))
//        favoritesBarButton.image = UIImage.init(named: "heart")?
//        favoritesBarButton.action = #selector(self.goToFavorites)
        clearBarButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = clearBarButton
        self.navigationController?.navigationBar.barTintColor = .orange
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().barTintColor = .orange
        
    }
    
    func setupUI() {
        
//        view.addSubview(tableView)
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.backgroundColor = .white
//        tableView.fixInView(view)
    }
    
    @objc func clearAllTapped() {
        try! realm.write({
            developers.forEach {
                $0.isFavorite = !$0.isFavorite
                realm.add($0, update: .all)
            }
        })
    }
}

extension FavoritesViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return developers.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DeveloperListCell.kCellId) as? DeveloperListCell
        
        let dev = developers[indexPath.row]
        
        cell?.configure(title: dev.login, score: dev.score, isFavorite: dev.isFavorite , imageURL: dev.avatarUrl ?? "", repo: imageRepo, realm: self.realm, index: indexPath.row)
//        cell?.delegate = self
        
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let dev = developers[indexPath.row]
            guard let realmDev = realm.object(ofType: Developer.self, forPrimaryKey: dev.id) else {
                return
            }
            
            try! realm.write({
                realmDev.isFavorite = !realmDev.isFavorite
                realm.add(realmDev, update: .all)
            })
        }
    }
    
}
