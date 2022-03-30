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
    var infoLabel = UILabel()
    var companyLabel = UILabel()
    var companyValueLabel = UILabel()
    var blogLabel = UILabel()
    var blogValueLabel = UILabel()
    var emailLabel = UILabel()
    var emailValueLabel = UILabel()
    var bioLabel = UILabel()
    var bioValueLabel = UILabel()
    var hireableLabel = UILabel()
    var additionalInfoLabel = UILabel()
    var nameLocationStack = UIStackView()
    var additionalInfoStack = UIStackView()
    var hireCircleView = UIView()
    
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
        configureViewConditionals()
        configureViewsProperties()
    }
    
    func addNeededSubviews() {
        view.addSubview(detailsView)
        detailsView.fixInView(self.view)
        //directly inside details view
        detailsView.addSubview(nameLocationStack)
        detailsView.addSubview(imageView)
        detailsView.addSubview(infoLabel)
        detailsView.addSubview(additionalInfoStack)
        
        //name and location stackView
        nameLocationStack.addSubview(nameLabel)
        nameLocationStack.addSubview(locationLabel)

        //additional information stackView
        additionalInfoStack.addSubview(hireableLabel)
        additionalInfoStack.addSubview(hireCircleView)
        additionalInfoStack.addSubview(companyLabel)
        additionalInfoStack.addSubview(companyValueLabel)
        additionalInfoStack.addSubview(blogLabel)
        additionalInfoStack.addSubview(blogValueLabel)
        additionalInfoStack.addSubview(emailLabel)
        additionalInfoStack.addSubview(emailValueLabel)
        additionalInfoStack.addSubview(bioLabel)
        additionalInfoStack.addSubview(bioValueLabel)

        //loading indicator
        view.addSubview(indicatorView)
    }
    
    func configureViewsProperties() {
        nameLocationStack.axis = .vertical
        nameLocationStack.alignment = .center
        
        additionalInfoStack.axis = .vertical
        additionalInfoStack.alignment = .center
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .black
        locationLabel.font = UIFont.systemFont(ofSize: 18)
        locationLabel.textColor = .orange
        locationLabel.textAlignment = .center
        locationLabel.adjustsFontSizeToFitWidth = true
        
        companyLabel.font = UIFont.italicSystemFont(ofSize: 14)
        companyValueLabel.font = UIFont.systemFont(ofSize: 14)
        blogLabel.font = UIFont.italicSystemFont(ofSize: 14)
        companyValueLabel.font = UIFont.systemFont(ofSize: 14)
        emailLabel.font = UIFont.italicSystemFont(ofSize: 14)
        companyValueLabel.font = UIFont.systemFont(ofSize: 14)
        bioLabel.font = UIFont.italicSystemFont(ofSize: 14)
        companyValueLabel.font = UIFont.systemFont(ofSize: 14)
        hireableLabel.font = UIFont.italicSystemFont(ofSize: 14)
        
        hireCircleView.layer.cornerRadius = kCircleRadius
        hireCircleView.clipsToBounds = true
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
        
        //label with text 'additional information'
        stickViewLeftRightToSuperview(view: infoLabel)
//
//        //all the available extra information for the developer company/bio etc.
//        adjustAdditionalInfoStackConstraints()
//
//        //center the loading indicator
        adjustIndicatorConstraints()
    }
    
    func adjustAdditionalInfoStackConstraints() {
        adjustAdditionalInfoFirstLastConstraints()

        stickViewLeftRightToSuperview(view: additionalInfoStack, left: kDefaultPadding, right: kDefaultPadding)
        additionalInfoStack.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: kDefaultPadding).isActive = true
        additionalInfoStack.bottomAnchor.constraint(greaterThanOrEqualTo: detailsView.bottomAnchor, constant: kDefaultPadding).isActive = true
        
        //hireable circle view
        hireCircleView.translatesAutoresizingMaskIntoConstraints = false
        hireCircleView.heightAnchor.constraint(equalToConstant: 2 * kCircleRadius).isActive = true
        hireCircleView.widthAnchor.constraint(equalToConstant: 2 * kCircleRadius).isActive = true
        hireCircleView.leftAnchor.constraint(equalTo: detailsView.leftAnchor, constant: kDefaultPadding).isActive = true
        hireCircleView.rightAnchor.constraint(equalTo: hireableLabel.leftAnchor, constant: kDefaultPadding).isActive = true
        
        //extra info labels
        adjustAdditionalInfoLabelConstraints(label: infoLabel, below: imageView)
        //company
        adjustAdditionalInfoLabelConstraints(label: companyLabel, below: hireableLabel)
        adjustAdditionalInfoLabelConstraints(label: companyValueLabel, below: companyLabel)
        //blog
        adjustAdditionalInfoLabelConstraints(label: blogLabel, below: companyValueLabel)
        adjustAdditionalInfoLabelConstraints(label: blogValueLabel, below: blogLabel)
        //email
        adjustAdditionalInfoLabelConstraints(label: emailLabel, below: blogValueLabel)
        adjustAdditionalInfoLabelConstraints(label: emailValueLabel, below: emailLabel)
        //bio
        adjustAdditionalInfoLabelConstraints(label: bioLabel, below: emailValueLabel)
        adjustAdditionalInfoLabelConstraints(label: bioValueLabel, below: bioLabel)
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
        locationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0.0).isActive = true
        locationLabel.bottomAnchor.constraint(equalTo: nameLocationStack.bottomAnchor, constant: 0.0).isActive = true
        
    }
    
    func adjustImageViewConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 2 * kDefaultPadding).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1).isActive = true
    }
    
    func adjustInfoLabelConstraints() {
        infoLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20.0).isActive = true
        
    }
    
    func adjustAdditionalInfoLabelConstraints(label: UILabel, below topView: UIView) {
        label.translatesAutoresizingMaskIntoConstraints = false
        stickViewLeftRightToSuperview(view: label)
        label.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: kDefaultPadding).isActive = true
    }
    
    func adjustAdditionalInfoFirstLastConstraints() {
        hireableLabel.topAnchor.constraint(equalTo: additionalInfoStack.topAnchor, constant: 0).isActive = true
        bioValueLabel.topAnchor.constraint(equalTo: additionalInfoStack.bottomAnchor, constant: 0).isActive = true
    }
    
    func configureViewConditionals() {
        let company: Bool = (developer?.company?.count ?? 0) > 0
        let blog: Bool = (developer?.blog?.count ?? 0) > 0
        let email: Bool = (developer?.email?.count ?? 0) > 0
        let bio: Bool = (developer?.bio?.count ?? 0) > 0
        
        companyLabel.isHidden = !company
        companyValueLabel.isHidden = !company
        
        blogLabel.isHidden = !blog
        blogValueLabel.isHidden = !blog
        
        emailLabel.isHidden = !email
        emailValueLabel.isHidden = !email
        
        bioLabel.isHidden = !bio
        bioValueLabel.isHidden = !bio
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
        view.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: right).isActive = true
    }
}
