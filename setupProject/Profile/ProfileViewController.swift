import UIKit
final class ProfileViewController: UIViewController{
    override func viewDidLoad(){
        //MARK: IMAGE
        let profileImage = UIImage(named: "profilePhoto")
        let avatarImageView = UIImageView(image: profileImage)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
        avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 32).isActive = true
        
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
        nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor,constant: 8).isActive = true
        
        let LoginNameLabel = UILabel()
        LoginNameLabel.font = UIFont(name: "SF-Pro-Display-Regular", size: 13)
        LoginNameLabel.textColor = .ypGray
        LoginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(LoginNameLabel)
        LoginNameLabel.text = "@ekaterina_nov"
        LoginNameLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        LoginNameLabel.leadingAnchor.constraint(equalTo: LoginNameLabel.leadingAnchor).isActive = true
        LoginNameLabel.topAnchor.constraint(equalTo: LoginNameLabel.bottomAnchor, constant: 8).isActive = true
        
        let descriptionLabel = UILabel()
        descriptionLabel.font = UIFont(name: "SF-Pro-Display-Regular", size: 13)
        descriptionLabel.textColor = .white
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.text = "Hello World!"
        descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: LoginNameLabel.bottomAnchor,constant: 8).isActive = true
        
        let buttonName = "quit"
        guard let imageButton = UIImage(named: buttonName) else{
            return print("image button not found")
            }
        let LoboutButton = UIButton.systemButton(
            with: imageButton,
            target: self,
            action: #selector(Self.didTapButton)
        )
        //BUTTON
        LoboutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(LoboutButton)
        LoboutButton.tintColor = .ypRed
        LoboutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        LoboutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor).isActive = true
        LoboutButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        LoboutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
    }
    @objc
    private func didTapButton() {}
}

