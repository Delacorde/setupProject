import Foundation
import setupProject
final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: setupProject.WebViewPresenterProtocol?
    var loadRequestCalled: Bool = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
    }
    
    func setProgressHidden(_ isHidden: Bool) {
    }
}
