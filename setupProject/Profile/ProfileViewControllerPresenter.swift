import Foundation
protocol ProfileViewControllerPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
}
final class ProfileViewControllerPresenter: ProfileViewControllerPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let logoutService = ProfileLogoutService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        if let profile = profileService.profile {
            view?.updateProfileDetails(
                name: profile.name,
                login: profile.loginName,
                bio: profile.bio ?? ""
            )
        }
        
        observeAvatarChanges()
        updateAvatar()
    }
    
    func didTapLogout() {
        logoutService.logout()
    }
    
    private func observeAvatarChanges() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        view?.updateAvatar(with: url)
    }
}
