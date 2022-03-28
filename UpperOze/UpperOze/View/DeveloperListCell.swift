//
//  DeveloperListCell.swift
//  UpperOze
//
//  Created by gabriel durican on 3/27/22.
//

import Foundation
import UIKit
import RealmSwift

let kLightOrange = UIColor(red: 255/255.0, green: 219/255.0, blue: 183/255.0, alpha: 1.0)

protocol DeveloperListCellDelegate {
    func tappedFavorite(cell: DeveloperListCell)
}

class DeveloperListCell: UITableViewCell {
    static let kCellId = "DevCellId"
    fileprivate var devImageView = UIImageView()
    fileprivate var favoriteButton = UIButton()
    var router: Router<ImageAPI>?
    var avatarUrl: String?
    var delegate: DeveloperListCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: DeveloperListCell.kCellId)
        backgroundColor = UIColor.white

        separatorInset = UIEdgeInsets.zero
        indentationWidth = 11
        indentationLevel = 10
        
        configureBackground()
        configureImageView()
        configureFavoriteButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureBackground() {
//        let view = UIView()
//        view.backgroundColor = kLightOrange
//        self.selectedBackgroundView = view
    }
    
    func configureImageView() {
        self.contentView.addSubview(devImageView)
        devImageView.layer.cornerRadius = 50.0
        devImageView.clipsToBounds = true
        devImageView.image = UIImage(named: "placeholder")
        devImageView.contentMode = .scaleAspectFit
        devImageView.backgroundColor = UIColor.lightGray
        devImageView.layer.borderColor = UIColor.orange.cgColor
        devImageView.layer.borderWidth = 2.0
        adjustImageViewConstraints()
    }
    
    func configureFavoriteButton() {
        contentView.addSubview(favoriteButton)
        favoriteButton.setImage(UIImage(named: "heart"), for: .normal)
        favoriteButton.addTarget(self, action: #selector(tappedFavorite), for: .touchUpInside)
        adjustFavoriteButtonConstraints()
    }
    
    @objc func tappedFavorite() {
        delegate?.tappedFavorite(cell: self)
    }
    
    func setNewImage(image: UIImage?) {
        guard let image = image else {
            return
        }

        devImageView.image = image
    }
    
    func adjustImageViewConstraints() {
        devImageView.translatesAutoresizingMaskIntoConstraints = false
        devImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        devImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15.0).isActive = true
        devImageView.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
        devImageView.widthAnchor.constraint(equalTo: devImageView.heightAnchor, multiplier: 1).isActive = true
    }
    
    func adjustFavoriteButtonConstraints() {
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15.0).isActive = true
        favoriteButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        favoriteButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func configure(title: String?, score: Double?, isFavorite: Bool, imageURL: String, repo: ImageRepository?, realm: Realm, index: Int) {
        #warning("GABI check https://stackoverflow.com/questions/63075418/how-to-use-ios-14-cell-content-configurations-in-general")
//        var contentConfig = self.defaultContentConfiguration()
//        contentConfig.text = title?.capitalized
//        contentConfig.textProperties.font = UIFont.systemFont(ofSize: 20)
//        contentConfig.secondaryText = "\(score ?? 0)"
//        contentConfig.textProperties.color = UIColor.blue
//        contentConfig.secondaryTextProperties.color = .blue
//        contentConfig.cont
        
//        favoriteButton.isHighlighted = (isFavorite == true)
        favoriteButton.backgroundColor = isFavorite == true ? .blue : .red
        
        
        self.avatarUrl = imageURL
        
//        self.contentConfiguration = contentConfig
        
        router = repo?.get(imageURL, completion: { [weak self] imageData, urlUsed, error in
            guard let self = self else {
                return
            }
            
            if self.avatarUrl != urlUsed {
                //cell is being reused, do not update the imageview or it will show the wrong image
                return
            }
            
            DispatchQueue.main.async {
                if error != nil && imageData == nil {
                    let realmImage = realm.object(ofType: ImageData.self, forPrimaryKey: index)
                    let image = UIImage(data: realmImage?.data ?? Data())
                    self.setNewImage(image: image)
                } else {
                    try! realm.write({
                        let img = ImageData(data: imageData, index: index, devName: title)

                        realm.add(img, update: .all)
                        self.setNewImage(image: UIImage(data: imageData ?? Data()))
                    })
                }
            }
        })
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        router?.cancel()
    }
}
