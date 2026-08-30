import Foundation
import WebKit

final class ProfileLogoutService{
    static let shared = ProfileLogoutService()
    private var splashViewController = SplashViewController()
    
    private init() {
    }
    func logout() {
        cleanCookies()
        cleanStorrageAndData()
        switchToSplashController()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                    records.forEach { record in
                        WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                    }
                }
            }
    private func cleanStorrageAndData(){
        OAuth2TokenStorage.shared.token = nil
    }
    private func switchToSplashController(){
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        window.rootViewController = splashViewController
    }
}
