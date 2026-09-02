import Foundation
@testable import setupProject

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfileViewControllerPresenterProtocol?
    var updateAvatarCalled = false
    var updateProfileDetailsCalled = false
    
    var lastUpdatedAvatarURL: URL?
    var lastUpdatedName: String?
    var lastUpdatedLogin: String?
    var lastUpdatedBio: String?
    
    func updateAvatar(with url: URL) {
        updateAvatarCalled = true
        lastUpdatedAvatarURL = url
    }
    
    func updateProfileDetails(name: String, login: String, bio: String) {
        updateProfileDetailsCalled = true
        lastUpdatedName = name
        lastUpdatedLogin = login
        lastUpdatedBio = bio
    }
}
