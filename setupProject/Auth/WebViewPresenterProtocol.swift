public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? {get set}
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}
import Foundation

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    func viewDidLoad() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            return print("Failed to create URLComponents")
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else {
            return print("Failed to create URL)")
        }
        guard let request = authHelper.authRequest() else { return }
        view?.load(request: request)
        didUpdateProgressValue(0)

        view?.load(request: request)
    }
    var authHelper: AuthHelperProtocol
    init(authHelper: AuthHelperProtocol){
        self.authHelper = authHelper
    }
    func didUpdateProgressValue(_ newValue: Double) {
            let newProgressValue = Float(newValue)
            view?.setProgressValue(newProgressValue)
            
            let shouldHideProgress = shouldHideProgress(for: newProgressValue)
            view?.setProgressHidden(shouldHideProgress)
        }
    func shouldHideProgress(for value: Float) -> Bool {
            abs(value - 1.0) <= 0.0001
        }
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
