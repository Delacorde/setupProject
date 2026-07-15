import UIKit


protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}


final class AuthViewController: UIViewController {
    @IBOutlet weak var enterButton: UIButton!
    private let identifier = "ShowWebView"
    
    weak var delegate: AuthViewControllerDelegate?
    
    private let oauth2Service = OAuth2Service.shared
    override func viewDidLoad(){
        super.viewDidLoad()
        
        configureBackButton()
    }
    private func configureBackButton(){
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == identifier {
                guard
                    let webViewViewController = segue.destination as? WebViewViewController
                else {
                    assertionFailure("Failed to prepare for \(identifier)")
                    return
                }
                webViewViewController.delegate = self
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        oauth2Service.fetchOAuthToken(code: code) { result in
            switch result{
            case . success(let token):
                let storageForToken = OAuth2TokenStorage()
                storageForToken.token = token
                vc.dismiss(animated: true)
            case .failure(let error):
                print(error)
            }
        }
    }
}
extension AuthViewController {
    private func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        oauth2Service.fetchOAuthToken(code: code) { result in
            completion(result)
        }
    }
}

