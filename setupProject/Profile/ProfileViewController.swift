import UIKit
class ProfileViewController: UIViewController{
    override func viewDidLoad(){
        //MARK: IMAGE
        let profileImage = UIImage(named: "profilePhoto")
        let image = UIImageView(image: profileImage)
        image.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(image)
        image.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        image.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 32).isActive = true
        
        //MARK:LABELS
        let nameLabel = UILabel()
        nameLabel.font = UIFont(name: "SF-Pro", size: 23)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.text = "Екатерина Новикова"
        nameLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 16).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 124).isActive = true
        nameLabel.topAnchor.constraint(equalTo: image.bottomAnchor,constant: 8).isActive = true
        
        let nickName = UILabel()
        nickName.font = UIFont(name: "SF-Pro-Display-Regular", size: 13)
        nickName.textColor = .ypGray
        nickName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nickName)
        nickName.text = "@ekaterina_nov"
        nickName.heightAnchor.constraint(equalToConstant: 18).isActive = true
        nickName.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        nickName.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        
        let bio = UILabel()
        bio.font = UIFont(name: "SF-Pro-Display-Regular", size: 13)
        bio.textColor = .white
        bio.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bio)
        bio.text = "Hello World!"
        bio.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        bio.topAnchor.constraint(equalTo: nickName.bottomAnchor,constant: 8).isActive = true
        
        let button = UIButton.systemButton(
            with: UIImage(named:"quit")!,
            target: self,
            action: #selector(Self.didTapButton)
        )
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.tintColor = .ypRed
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        button.centerYAnchor.constraint(equalTo: image.centerYAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
    }
    @objc
    private func didTapButton() {}
}

