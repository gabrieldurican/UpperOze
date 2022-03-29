import Foundation
import UIKit
import RealmSwift

class DeveloperViewController: BaseViewController {
    var developer: Developer?
    var devLogin: String?
    var imageUrl: String?
    var detailsView = UIView()
    var imageView = UIImageView()
    var nameLabel = UILabel()
    var locationLabel = UILabel()
    var companyLabel = UILabel()
    var blogLabel = UILabel()
    var emailLabel = UILabel()
    var bioLabel = UILabel()
    var hireableLabel = UILabel()
    
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
                self.showErrorAlert(error: "object deleted")
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        adjustImageViewConstraints()
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
        detailsView.addSubview(imageView)
        detailsView.addSubview(companyLabel)
        detailsView.addSubview(nameLabel)
        detailsView.addSubview(locationLabel)
        detailsView.addSubview(blogLabel)
        detailsView.addSubview(emailLabel)
        detailsView.addSubview(bioLabel)
        detailsView.addSubview(hireableLabel)
        view.addSubview(indicatorView)
    }
    
    func configureConstraints() {
        adjustNameLabelConstraints()
        adjustLabelConstraints(label: locationLabel, below: nameLabel)
        adjustLabelConstraints(label: companyLabel, below: imageView)
        adjustLabelConstraints(label: blogLabel, below: companyLabel)
        adjustLabelConstraints(label: emailLabel, below: blogLabel)
        adjustLabelConstraints(label: bioLabel, below: emailLabel)
        adjustLabelConstraints(label: hireableLabel, below: bioLabel)
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func configureViewsProperties() {
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .black
        locationLabel.font = UIFont.systemFont(ofSize: 18)
        locationLabel.textColor = .orange
        locationLabel.textAlignment = .center
        locationLabel.adjustsFontSizeToFitWidth = true
        companyLabel.font = UIFont.systemFont(ofSize: 14)
        blogLabel.font = UIFont.systemFont(ofSize: 14)
        emailLabel.font = UIFont.systemFont(ofSize: 14)
        bioLabel.font = UIFont.systemFont(ofSize: 14)
        hireableLabel.font = UIFont.systemFont(ofSize: 14)
        companyLabel.textColor = .black
    }
    
    func updateUI(_ dev: Developer?) {
        guard let dev = dev else {
            return
        }
        
        hideLoading()
        detailsView.isHidden = false
        
        //connect the model values to the UI elements
        nameLabel.text = dev.name
        locationLabel.text = dev.location
        companyLabel.attributedText = createTextWith(prefixText: "Company", valueText: dev.company ?? "")
        blogLabel.attributedText = createTextWith(prefixText: "Blog", valueText: dev.blog ?? "")
        emailLabel.attributedText = createTextWith(prefixText: "Email", valueText: dev.email ?? "")
        bioLabel.attributedText = createTextWith(prefixText: "Bio", valueText: dev.bio ?? "")
        hireableLabel.text = dev.hireable == true ? "hireable" : "not hireable"
        hireableLabel.textColor = dev.hireable == true ? .green : .red
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

    func adjustImageViewConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 50).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1).isActive = true
    }
    
    func adjustNameLabelConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15.0).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15.0).isActive = true
        nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
    }
    
    func adjustLabelConstraints(label: UILabel, below topView: UIView) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15.0).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15.0).isActive = true
        label.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 15).isActive = true
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
}
