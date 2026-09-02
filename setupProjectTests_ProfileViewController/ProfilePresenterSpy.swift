import Foundation
@testable import setupProject

final class ProfilePresenterSpy: ProfileViewControllerPresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var didTapLogoutCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogout() {
        didTapLogoutCalled = true
    }
}
