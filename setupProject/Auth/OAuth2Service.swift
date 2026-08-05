import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private let dataStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    private var currentTaskID : UUID?
    
    private(set) var authToken: String? {
        get {
            return dataStorage.token
        }
        set {
            dataStorage.token = newValue
        }
    }
    
    private init() { }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            print("[OAuth2Service.fetchOAuthToken]: AuthServiceError - повторный запрос с кодом: \(code)")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        let taskID = UUID()
        currentTaskID = taskID
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service.fetchOAuthToken]: AuthServiceError - не удалось создать URLRequest для кода: \(code)")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard self.currentTaskID == taskID else {
                    print("[OAuth2Service.fetchOAuthToken]: пропуск  отмененного запроса для кода: \(code)")
                    return
                }
                
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    self.authToken = authToken
                    
                    self.task = nil
                    self.lastCode = nil
                    self.currentTaskID = nil
                    completion(.success(authToken))
                case .failure(let error):
                    if let urlError = error as? URLError, urlError.code == .cancelled {
                        
                        print("[OAuth2Service.fetchOAuthToken]: реквест отменен для кода : \(code)")
                        return
                    }
                    print("[OAuth2Service.fetchOAuthToken]: RequestError - \(error) for code: \(code)")
                    
                    self.task = nil
                    self.lastCode = nil
                    self.currentTaskID = nil
                    
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let authTokenUrl = urlComponents.url else { return nil }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
    
    private struct OAuthTokenResponseBody: Codable {
        let accessToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
}
