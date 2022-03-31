import Foundation
import UIKit
import RealmSwift

class DeveloperViewController: BaseViewController {
    let kCircleRadius = 15.0
    let kDefaultFontSize = 14.0
    let kDefaultPadding = 15.0
    
    var developer: Developer?
    var devLogin: String?
    var imageUrl: String?
    var detailsView = UIView()
    var imageView = UIImageView()
    var nameLabel = UILabel()
    var locationLabel = UILabel()
    var nameLocationStack = UIStackView()
    var additionalInfoView: AdditionalDeveloperInfoView?
    
    
    lazy var indicatorView: UIActivityIndicatorView = {
        let iv = UIActivityIndicatorView(style: .large)
        iv.color = .orange
        iv.hidesWhenStopped = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        return iv
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(devLogin: String, imageUrl: String) {
        self.devLogin = devLogin
        self.imageUrl = imageUrl
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startObservingRealm()
        configureImageView()
        configureUI()
    }
    
    func startObservingRealm() {
        developer = realm?.object(ofType: Developer.self, forPrimaryKey: devLogin)

        notificationToken = developer?.observe { [weak self] change in
            guard let self = self else {
                return
            }
            
            switch change {
            case .change(_, _):
                self.updateUI(self.developer)
            case .error(let error):
                self.showErrorAlert(error: error.localizedDescription)
            case .deleted:
                self.showErrorAlert(error: " object deleted")
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareData()
        loadImage()
        getDeveloperInfo()
    }
    
    func prepareData() {
        showLoading()
        detailsView.isHidden = true
    }
    
    
    func loadImage() {
        guard let realm = realm, let devLogin = devLogin, let imageUrl = imageUrl else {
            return
        }

        imageRepo.getData(imageUrl, linkedId: devLogin, realm: realm) { [weak self] data, urlUsed, error in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                var forUseData: Data?
                if data == nil && error != nil {
                    let realmImage = realm.object(ofType: ImageData.self, forPrimaryKey: self.developer?.login)
                    forUseData = realmImage?.data
                } else {
                    forUseData = data
                }
            
                self.imageView.image = UIImage(data: forUseData ?? Data())
            }
            
        }
    }
    
    
    func getDeveloperInfo() {
        guard let devLogin = devLogin, let realm = realm else {
            return
        }
        
        devRepo.get(devLogin, realm: realm) { [weak self] dev, error in
            if error != nil && dev == nil {
                DispatchQueue.main.async {
                    self?.updateUI(self?.developer)
                }
            }
            
            self?.hideLoading()
        }
    }
    
    func configureUI() {
        self.title = devLogin?.capitalized
        
        addNeededSubviews()
        configureConstraints()
        configureViewsProperties()
    }
    
    func addNeededSubviews() {
        view.addSubview(detailsView)
        detailsView.fixInView(self.view)
        //directly inside details view
        detailsView.addSubview(nameLocationStack)
        detailsView.addSubview(imageView)
        additionalInfoView = AdditionalDeveloperInfoView(developer: self.developer)
        detailsView.addSubview(additionalInfoView ?? UIView())
        
        //name and location stackView
        nameLocationStack.addSubview(nameLabel)
        nameLocationStack.addSubview(locationLabel)

        //loading indicator
        view.addSubview(indicatorView)
    }
    
    func configureViewsProperties() {
        nameLocationStack.axis = .vertical
        nameLocationStack.alignment = .center
        nameLocationStack.spacing = 0.0
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .black
        locationLabel.font = UIFont.systemFont(ofSize: 18)
        locationLabel.textColor = .orange
        locationLabel.textAlignment = .center
        locationLabel.adjustsFontSizeToFitWidth = true
    }
    
    
    func configureImageView() {
        imageView.layer.cornerRadius = 100.0
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "placeholder")
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.lightGray
        imageView.layer.borderColor = UIColor.orange.cgColor
        imageView.layer.borderWidth = 2.0
    }

    func configureConstraints() {
        //name and location stack view
        adjustNameLocationConstraints()
        
        //image view
        adjustImageViewConstraints()
        
        adjustAdditionalInfoViewConstraints()

        //center the loading indicator
        adjustIndicatorConstraints()
    }
    
    func adjustAdditionalInfoViewConstraints() {
        additionalInfoView?.translatesAutoresizingMaskIntoConstraints = false
        additionalInfoView?.stickLeftRightToSuperview(left: kDefaultPadding, right: kDefaultPadding)
        additionalInfoView?.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: kDefaultPadding).isActive = true
        additionalInfoView?.bottomAnchor.constraint(greaterThanOrEqualTo: detailsView.bottomAnchor, constant: -kDefaultPadding).isActive = true
    }
    
    func adjustIndicatorConstraints() {
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func adjustNameLocationConstraints() {
        nameLocationStack.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLocationStack.centerXAnchor.constraint(equalTo: detailsView.centerXAnchor).isActive = true
        nameLocationStack.topAnchor.constraint(equalTo: detailsView.topAnchor, constant: 2 * kDefaultPadding).isActive = true
        nameLabel.topAnchor.constraint(equalTo: nameLocationStack.topAnchor, constant: kDefaultPadding).isActive = true
        locationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0.0).isActive = true
        stickViewLeftRightToSuperview(view: nameLabel)
        stickViewLeftRightToSuperview(view: locationLabel)
        locationLabel.bottomAnchor.constraint(equalTo: nameLocationStack.bottomAnchor, constant: 0.0).isActive = true
    }
    
    func adjustImageViewConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: nameLocationStack.bottomAnchor, constant: 2 * kDefaultPadding).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 200.0).isActive = true
    }

    
    func updateUI(_ dev: Developer?) {
        guard let dev = dev else {
            return
        }
        
        hideLoading()
        additionalInfoView?.developer = developer
        detailsView.isHidden = false
        
        //connect the model values to the UI elements
        nameLabel.text = dev.name
        locationLabel.text = dev.location
    }
    
    func showErrorAlert(error: String?) {
        let message = "An error occured" + ":\(error ?? "")"
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel) { action in
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    
    func showLoading() {
        DispatchQueue.main.async {
            self.indicatorView.startAnimating()
        }
        
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.indicatorView.stopAnimating()
        }
    }
    
    func createTextWith(prefixText: String, valueText: String) -> NSAttributedString {
        let fullText = prefixText + ": " + valueText
        let range = (fullText as NSString).range(of: prefixText)

        let mutableAttributedString = NSMutableAttributedString.init(string: fullText)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.orange, range: range)
        
        return mutableAttributedString
    }
    
    //helpers
    func stickViewLeftRightToSuperview(view: UIView, left: CGFloat = 0, right: CGFloat = 0) {
        guard let superview = view.superview else {
            return
        }
        
        view.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: left).isActive = true
        view.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -right).isActive = true
    }
}
