import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet private weak var webView: WKWebView!
    
    @IBOutlet weak var progressView: UIProgressView!
    // MARK: Delegate
    weak var delegate: WebViewViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?

    // MARK: viewdedload
    override func viewDidLoad(){
        super.viewDidLoad()
        loadAuthView()
        webView.navigationDelegate = self
        estimatedProgressObservation = webView.observe(
                    \.estimatedProgress,
                    options: [],
                    changeHandler: { [weak self] _, _ in
                        guard let self = self else { return }
                        self.updateProgress()
                    })
    }
    
    //MARK: funcs
    private func loadAuthView(){
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
        let request = URLRequest(url: url)
        webView.load(request)
    }
    override func viewWillAppear(_ animateed:Bool){
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil
        )
        
        updateProgress()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
//MARK: Enums
    enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }
}
// MARK extensions
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        guard let url = navigationAction.request.url else {
            print(" Failed to get URL")
            return nil
        }
        guard let urlComponents = URLComponents(string: url.absoluteString) else {
            print("Failed to create URLComponents")
            return nil
        }
        guard urlComponents.path == "/oauth/authorize/native" else {
            print("URL path is not '/oauth/authorize/native'")
            return nil
        }
        guard let items = urlComponents.queryItems else {
            print("No query items in URL")
            return nil
        }
        guard let codeItem = items.first(where: { $0.name == "code" }) else {
            print("No 'code' parameter found in query items")
            return nil
        }
        guard let code = codeItem.value else {
            print("code parameter has no value")
            return nil
        }
        return code
    }
}
