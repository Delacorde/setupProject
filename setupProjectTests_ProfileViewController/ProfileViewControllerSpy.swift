import Foundation
@testable import setupProject

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfileViewControllerPresenterProtocol?
    var updateAvatarCalled: Bool = false
    var updateProfileDetailsCalled: Bool = false
    
    func updateAvatar(with url: URL) {
        updateAvatarCalled = true
    }
    
    func updateProfileDetails(name: String, login: String, bio: String) {
        updateProfileDetailsCalled = true
    }
}
