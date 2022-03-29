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
    var loginLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: DeveloperListCell.kCellId)
        backgroundColor = UIColor.white

        separatorInset = UIEdgeInsets.zero
        indentationWidth = 11
        indentationLevel = 10
        
        configureBackground()
        configureImageView()
        configureFavoriteButton()
        configureLabels()
        contentView.addSubview(loginLabel)
        adjustLabelConstraints()
        selectionStyle = .none
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureBackground() {
        let view = UIView()
        view.backgroundColor = .clear
        self.selectedBackgroundView = view
    }
    
    func configureLabels() {
        loginLabel.textColor = UIColor.black
        loginLabel.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    func configureImageView() {
        contentView.addSubview(devImageView)
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
        favoriteButton.setImage(UIImage(named: "starDefault"), for: .normal)
        favoriteButton.setImage(UIImage(named: "starSelected"), for: .highlighted)
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
    
    func adjustLabelConstraints() {
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        loginLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        loginLabel.leftAnchor.constraint(equalTo: devImageView.rightAnchor, constant: 15).isActive = true
        loginLabel.rightAnchor.constraint(greaterThanOrEqualTo: favoriteButton.leftAnchor, constant: 10).isActive = true
    }
    
    func configure(developer: Developer, repo: ImageRepository?, realm: Realm, showFavorite: Bool = true) {
        favoriteButton.isHidden = !showFavorite
        favoriteButton.isHighlighted = developer.isFavorite == true
        loginLabel.text = developer.login?.capitalized
       
        self.avatarUrl = developer.avatarUrl
        
        router = repo?.getData(developer.avatarUrl ?? "", linkedId: developer.login ?? "", realm: realm, completion: { [weak self] imageData, urlUsed, error in
            guard let self = self else {
                return
            }
            
            if self.avatarUrl != urlUsed {
                //cell is being reused, do not update the imageview or it will show the wrong image
                return
            }
            
            DispatchQueue.main.async {
                var data: Data?
                if imageData == nil && error != nil {
                    let realmImage = realm.object(ofType: ImageData.self, forPrimaryKey: developer.login)
                    data = realmImage?.data
                } else {
                    data = imageData
                }
                self.setNewImage(image: UIImage(data: data ?? Data()))
            }
            
        })
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        router?.cancel()
    }
}
