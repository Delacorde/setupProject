import UIKit
final class ProfileViewController: UIViewController{
    //MARK: Properties
    let profileService = ProfileServce()
    
        private let nameLabel = UILabel()
        private let nickName = UILabel()
        private let bio = UILabel()
        private let quitButton = UIButton()
    
    //MARK: ViewDidLoad
    override func viewDidLoad(){
        super.viewDidLoad()
        profileService.fetchProfile(
            Constants.accessKey) { result in
                switch result {
                case .success(let profile):
                    self.updateProfile(profile: profile)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        //MARK: IMAGE
        let profileImage = UIImage(named: "profilePhoto")
        let image = UIImageView(image: profileImage)
        image.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(image)
        image.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        image.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 32).isActive = true
        
        //MARK:LABELS
        nameLabel.font = UIFont(name: "SF-Pro", size: 23)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.text = "Екатерина Новикова"
        nameLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 16).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 124).isActive = true
        nameLabel.topAnchor.constraint(equalTo: image.bottomAnchor,constant: 8).isActive = true
        
        nickName.font = UIFont(name: "SF-Pro-Display-Regular", size: 13)
        nickName.textColor = .ypGray
        nickName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nickName)
        nickName.text = "@ekaterina_nov"
        nickName.heightAnchor.constraint(equalToConstant: 18).isActive = true
        nickName.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        nickName.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        
        bio.font = UIFont(name: "SF-Pro-Display-Regular", size: 13)
        bio.textColor = .white
        bio.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bio)
        bio.text = "Hello World!"
        bio.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        bio.topAnchor.constraint(equalTo: nickName.bottomAnchor,constant: 8).isActive = true
        
        let buttonName = "quit"
        guard let imageButton = UIImage(named: buttonName) else{
            return print("image button not found")
        }
        let button = UIButton.systemButton(
            with: imageButton,
            target: self,
            action: #selector(Self.didTapButton)
        )
        //BUTTON
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.tintColor = .ypRed
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        button.centerYAnchor.constraint(equalTo: image.centerYAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    //MARK: funcs
    func updateProfile(profile: Profile){
        nameLabel.text = profile.name
                nickName.text = profile.loginName
                bio.text = profile.bio ?? "no bio"
    }
    @objc
    private func didTapButton() {}
}

