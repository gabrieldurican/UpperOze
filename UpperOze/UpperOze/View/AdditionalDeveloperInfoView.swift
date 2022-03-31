import Foundation
import UIKit

class AdditionalDeveloperInfoView: UIView {
    let kCircleRadius = 15.0
    let kDefaultFontSize = 14.0
    let kDefaultPadding = 15.0

    var companyLabel = UILabel()
    var companyValueLabel = UILabel()
    var blogLabel = UILabel()
    var blogValueLabel = UILabel()
    var emailLabel = UILabel()
    var emailValueLabel = UILabel()
    var bioLabel = UILabel()
    var bioValueLabel = UILabel()
    var hireableLabel = UILabel()
    var hireCircleView = UIView()
    var hireContainerView = UIView()
    var infoLabel = UILabel()
    var additionalInfoStack = UIStackView()
    var additionalInfoLabels = [UILabel]()
    
    var developer: Developer? {
        didSet {
            updateViewConditionals()
        }
    }
    
    init(developer: Developer?) {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        self.developer = developer
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        addNeededSubviews()
        configureConstraints()
        configureViews()
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func addNeededSubviews() {
        addSubview(infoLabel)
        addSubview(additionalInfoStack)
        hireContainerView.addSubview(hireableLabel)
        hireContainerView.addSubview(hireCircleView)
        additionalInfoStack.addArrangedSubview(hireContainerView)
        additionalInfoLabels.append(companyLabel)
        additionalInfoLabels.append(companyValueLabel)
        additionalInfoLabels.append(blogLabel)
        additionalInfoLabels.append(blogValueLabel)
        additionalInfoLabels.append(emailLabel)
        additionalInfoLabels.append(emailValueLabel)
        additionalInfoLabels.append(bioLabel)
        additionalInfoLabels.append(bioValueLabel)
        
        additionalInfoLabels.forEach {
            additionalInfoStack.addArrangedSubview($0)
        }
    }
    
    func configureViews() {
        additionalInfoStack.axis = .vertical
        additionalInfoStack.alignment = .center
        additionalInfoStack.spacing = kDefaultPadding
        
        companyLabel.font = UIFont.italicSystemFont(ofSize: kDefaultFontSize)
        companyValueLabel.font = UIFont.systemFont(ofSize: kDefaultFontSize)
        blogLabel.font = UIFont.italicSystemFont(ofSize: kDefaultFontSize)
        companyValueLabel.font = UIFont.systemFont(ofSize: kDefaultFontSize)
        emailLabel.font = UIFont.italicSystemFont(ofSize: kDefaultFontSize)
        companyValueLabel.font = UIFont.systemFont(ofSize: kDefaultFontSize)
        bioLabel.font = UIFont.italicSystemFont(ofSize: kDefaultFontSize)
        bioValueLabel.numberOfLines = 0
        companyValueLabel.font = UIFont.systemFont(ofSize: kDefaultFontSize)
        hireableLabel.font = UIFont.italicSystemFont(ofSize: kDefaultFontSize)
        hireableLabel.textColor = .black
        additionalInfoLabels.forEach {
            $0.textColor = .black
        }
        
        hireCircleView.layer.cornerRadius = kCircleRadius
        hireCircleView.clipsToBounds = true
    }
    
    func configureConstraints() {
        additionalInfoStack.translatesAutoresizingMaskIntoConstraints = false

        additionalInfoStack.stickLeftRightToSuperview(left: kDefaultPadding, right: kDefaultPadding)
        additionalInfoStack.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: kDefaultPadding).isActive = true

        //hire view
        hireCircleView.translatesAutoresizingMaskIntoConstraints = false
        hireableLabel.translatesAutoresizingMaskIntoConstraints = false
        hireContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        hireCircleView.heightAnchor.constraint(equalToConstant: 2 * kCircleRadius).isActive = true
        hireCircleView.widthAnchor.constraint(equalToConstant: 2 * kCircleRadius).isActive = true
        hireCircleView.leftAnchor.constraint(equalTo: hireContainerView.leftAnchor, constant: 0.0).isActive = true
        hireCircleView.rightAnchor.constraint(equalTo: hireableLabel.leftAnchor, constant: -kDefaultPadding).isActive = true
        hireableLabel.rightAnchor.constraint(equalTo: hireContainerView.rightAnchor, constant: -kDefaultPadding).isActive = true
        hireableLabel.centerYAnchor.constraint(equalTo: hireContainerView.centerYAnchor).isActive = true
        hireCircleView.centerYAnchor.constraint(equalTo: hireContainerView.centerYAnchor).isActive = true
        hireContainerView.heightAnchor.constraint(equalToConstant: 2 * kCircleRadius).isActive = true
        
        hireContainerView.stickLeftRightToSuperview()
        companyLabel.stickLeftRightToSuperview()
        companyValueLabel.stickLeftRightToSuperview()
        blogLabel.stickLeftRightToSuperview()
        blogValueLabel.stickLeftRightToSuperview()
        emailLabel.stickLeftRightToSuperview()
        emailValueLabel.stickLeftRightToSuperview()
        bioLabel.stickLeftRightToSuperview()
        bioValueLabel.stickLeftRightToSuperview()
    }
    
    func updateViewConditionals() {
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
    
    func updateUI() {
        infoLabel.text = "Additional information"
        companyLabel.text = "Company"
        companyValueLabel.text = developer?.company
        blogLabel.text = "Blog"
        blogValueLabel.text = developer?.blog
        emailLabel.text = "Email"
        emailValueLabel.text = developer?.email
        bioLabel.text = "Bio"
        bioValueLabel.text = developer?.bio
        hireableLabel.text = developer?.hireable == true ? "Hireable" : "Not hireable"
        hireCircleView.backgroundColor = developer?.hireable == true ? .green : .red
        
        updateViewConditionals()
    }
}
