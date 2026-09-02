import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject{
    var presenter: ProfileViewControllerPresenterProtocol? {get set}
    func updateAvatar(with url: URL)
    func updateProfileDetails(name:String, login: String, bio: String)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    // MARK: - Properties
    var presenter: ProfileViewControllerPresenterProtocol?
    
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let nickNameLabel = UILabel()
    private let bioLabel = UILabel()
    private let quitButton = UIButton()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        setupUI()
        
        if presenter == nil {
            let presenter = ProfileViewControllerPresenter()
            presenter.view = self
            self.presenter = presenter
        }
        
        presenter?.viewDidLoad()
    }
    func updateProfileDetails(name: String, login: String, bio: String) {
        nameLabel.text = name
        nickNameLabel.text = login
        bioLabel.text = bio
    }
    func updateAvatar(with url: URL) {
        let placeholder = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .processor(RoundCornerImageProcessor(cornerRadius: 35)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ]
        )
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // Avatar Image
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.clipsToBounds = true
        view.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ])
        
        // Name Label
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8)
        ])
        
        // Nickname Label
        nickNameLabel.font = UIFont.systemFont(ofSize: 13)
        nickNameLabel.textColor = .ypGray
        nickNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nickNameLabel)
        
        NSLayoutConstraint.activate([
            nickNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            nickNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            nickNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
        
        // Bio Label
        bioLabel.font = UIFont.systemFont(ofSize: 13)
        bioLabel.textColor = .white
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bioLabel)
        
        NSLayoutConstraint.activate([
            bioLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            bioLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            bioLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 8)
        ])
        
        // Quit Button
        guard let imageButton = UIImage(named: "quit") else { return }
        quitButton.setImage(imageButton, for: .normal)
        quitButton.tintColor = .ypRed
        quitButton.translatesAutoresizingMaskIntoConstraints = false
        quitButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        view.addSubview(quitButton)
        
        NSLayoutConstraint.activate([
            quitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            quitButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            quitButton.widthAnchor.constraint(equalToConstant: 44),
            quitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    @objc private func didTapButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        let noAction = UIAlertAction(title: "Нет", style: .default)
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.presenter?.didTapLogout()                }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true)
    }
}
