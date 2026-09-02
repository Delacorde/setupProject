import Foundation
@testable import setupProject

final class ProfilePresenterSpy: ProfileViewControllerPresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var didTapLogoutCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogout() {
        didTapLogoutCalled = true
    }
}
