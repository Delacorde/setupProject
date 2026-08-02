import UIKit
import ProgressHUD
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
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()

        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result{
            case .success:
                self.delegate?.didAuthenticate(self)
            case .failure:
                        let alert = UIAlertController(
                            title: "Что-то пошло не так",
                            message: "Не удалось войти в систему",
                            preferredStyle: .alert
                        )

                        alert.addAction(
                            UIAlertAction(title: "Ок", style: .default)
                        )

                        self.present(alert, animated: true)
                    }
                }
            }
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
extension AuthViewController {
    private func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        oauth2Service.fetchOAuthToken(code) { result in
            completion(result)
        }
    }
}


