//
//  ViewController.swift
//  UpperOze
//
//  Created by gabriel durican on 3/23/22.
//

import UIKit
import RealmSwift

class DeveloperListViewController: UITableViewController {
//    var developers: [Developer] = []
    var developers: Results<Developer>
//    var images: Results<ImageData>
    var repository: DevRepository?
    var imageRepo: ImageRepository?
    var realm: Realm
    var notificationToken: NotificationToken?
    var imageNotificationToken: NotificationToken?
    
    var limitIndex: Int = 0
    var currentPage: Int = 1
    var offset: Int = 5
    var maxPage = 30
    
    init(userRealmConfiguration: Realm.Configuration) {
        self.realm = try! Realm(configuration: userRealmConfiguration)
        developers = realm.objects(Developer.self).sorted(byKeyPath: "login")
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
    
//    func updateImagesForIndexes(indexes: [Int]) {
//        indexes.forEach({
//            let image = self.images[$0]
//            let cell = self.tableView.cellForRow(at: IndexPath(row: image.index ?? 0, section: 0)) as? DeveloperListCell
//            
//            cell?.setNewImage(image: UIImage(data: image.data ?? Data()))
//        })
//    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .orange
        tableView.register(DeveloperListCell.self, forCellReuseIdentifier: DeveloperListCell.kCellId)
        
        repository = DevRepository()
        imageRepo = ImageRepository()
        //setup navigation stuff
        title = "Lagos developers"
        let favoritesBarButton = UIBarButtonItem(image: UIImage.init(named: "heart"), style: .done, target: self, action: #selector(goToFavorites))
//        favoritesBarButton.image = UIImage.init(named: "heart")?
//        favoritesBarButton.action = #selector(self.goToFavorites)
        
        favoritesBarButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = favoritesBarButton
        self.navigationController?.navigationBar.barTintColor = .orange
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().barTintColor = .orange
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getDevelopersForPage(page: currentPage)
    }
    
    func getDevelopersForPage(page: Int) {
        repository?.getListPage(page, completion: { [weak self] devPage, error in
            print("GET FOR PAGE \(page)")
            guard let self = self else {
                return
            }
            
            guard let devPage = devPage, devPage.developers.count > 0 else {
                return
            }
            
            DispatchQueue.main.async {
                try! self.realm.write({
//                    self.realm.add(devPage, update: .modified)
                    devPage.developers.forEach( {
                        self.realm.add($0, update: .all)
                    })
                })
            self.limitIndex = self.developers.count - self.offset
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
            }
        })
    }

    @objc func goToFavorites() {
        let fav = FavoritesViewController(userRealmConfiguration: Realm.Configuration.defaultConfiguration)
//
        self.navigationController?.pushViewController(fav, animated: true)
    }
}

extension DeveloperListViewController {
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
        
        cell?.configure(title: dev.login, score: dev.score, isFavorite: dev.isFavorite, imageURL: dev.avatarUrl ?? "", repo: imageRepo, realm: self.realm, index: indexPath.row)
        cell?.delegate = self
//        cell?.configure(title: dev.name, score: dev.score, imageURL: <#T##URL#>)
//        var contentConfig = cell?.defaultContentConfiguration()
//        contentConfig?.text = dev.name
//        contentConfig?.textProperties.font = UIFont.systemFont(ofSize: 20)
//        contentConfig?.secondaryText = "\(dev.score ?? 0)"
//        contentConfig?.textProperties.color = UIColor.blue
//        contentConfig?.secondaryTextProperties.color = .blue

//        imageRepo?.get(dev.avatarUrl ?? "", completion: { image, error in
//            DispatchQueue.main.async {
//                let img = ImageData(data: image?.pngData(), index: indexPath.row, devName: dev.name)
//                self.realm.add(img, update: .modified)
//            }
//        })
        
//        if images.count > indexPath.row {
//            let img = images[indexPath.row] as ImageData
//            cell?.setNewImage(image: UIImage.init(data: img.data ?? Data()))
//        } else {
        
//        if (dev.imageData?.devName?.count ?? 0) > 0 {
//            cell?.setNewImage(image: UIImage(data: dev.imageData?.data ?? Data()))
//        } else {
//            imageRepo?.get(dev.avatarUrl ?? "", completion: { image, error in
//                DispatchQueue.main.async {
//                    cell?.setNewImage(image: image)
//                    try! self.realm.write({
//                        let img = ImageData(data: image?.pngData(), index: indexPath.row, devName: dev.name)
//                        //                        print("ADDED \(dev.name) -- \(indexPath.row)")
//                        //                        self.realm.add(img, update: .modified)
//                        dev.imageData = img
//                        self.realm.add(dev, update: .modified)
//                    })
//                }
//            })
//        }
        
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dev = developers[indexPath.row]
        let vc = DeveloperViewController.init(developer: dev, realm: realm, index: indexPath.row)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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

extension DeveloperViewController {
    #warning("GABI CHECK THE NAVIGATOR")
    
}

extension DeveloperListViewController: DeveloperListCellDelegate {
    func tappedFavorite(cell: DeveloperListCell) {
        #warning("GABI move to a method")
        guard let index = self.tableView.indexPath(for: cell), index.row < developers.count else {
            return
        }
        
        let dev = developers[index.row]
        guard let realmDev = realm.object(ofType: Developer.self, forPrimaryKey: dev.id) else {
            return
        }
        
        try! realm.write({
            realmDev.isFavorite = !realmDev.isFavorite
            realm.add(realmDev, update: .all)
        })
    }
}

