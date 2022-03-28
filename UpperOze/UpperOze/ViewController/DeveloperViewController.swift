//
//  DeveloperViewController.swift
//  UpperOze
//
//  Created by gabriel durican on 3/27/22.
//

import Foundation
import UIKit
import RealmSwift

class DeveloperViewController: UIViewController {
    var developer: Developer
    var index: Int
    var realm: Realm
    
    var imageView = UIImageView()
    
    init(developer: Developer, realm: Realm, index: Int) {
        self.developer = developer
        self.index = index
        self.realm = realm
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.green
        configureImageView()
        let image = realm.object(ofType: ImageData.self, forPrimaryKey: index)
        imageView.image = UIImage(data: image?.data ?? Data())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        adjustImageViewConstraints()
        
//        let image = realm.object(ofType: ImageData.self, forPrimaryKey: index)
//        imageView.image = UIImage(data: image?.data ?? Data())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
                

    }
    
    func configureImageView() {
        self.view.addSubview(imageView)
        imageView.layer.cornerRadius = 100.0
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "placeholder")
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.lightGray
        imageView.layer.borderColor = UIColor.orange.cgColor
        imageView.layer.borderWidth = 2.0
        
    }

    
    func adjustImageViewConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1).isActive = true
    }
    
}
