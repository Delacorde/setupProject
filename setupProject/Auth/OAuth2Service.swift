import Foundation

enum AuthServiceError: Error{
    case invalidRequest
}
class OAuth2Service {
    struct OAuthTokenResponseBody: Decodable{
        let access_token: String
    }
    // MARK: Properties
    private var lastCode: String?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    weak var delegate: OAuth2ServiceDelegate?
    static let shared = OAuth2Service()
    private init() {}
    
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                
            }
        } else {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
        guard
            let request = makeOAuthTokenRequest(code: code)
        else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        let task = urlSession.objectTask(
            for: request
        ) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            self?.task = nil
            self?.lastCode = nil

            switch result {
            case .success(let tokenResponse):
                completion(.success(tokenResponse.access_token))

            case .failure(let error):
                print("[OAuth2Service.fetchOAuthToken]: \(error)")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        guard let authTokenUrl = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
}

