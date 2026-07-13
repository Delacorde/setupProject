import UIKit

class OAuth2Service {
    struct OAuthTokenResponseBody: Decodable{
        let access_token: String
    }
    
    weak var delegate: OAuth2ServiceDelegate?
    static let shared = OAuth2Service()
    private init() {}
    
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
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
            guard let request = makeOAuthTokenRequest(code: code) else {
                completion(.failure(NetworkError.invalidRequest))
                return
            }
            let task = URLSession.shared.data(for: request) { result in
                switch result{
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                        let token = response.access_token
                        self.delegate?.didAuthenticate(token: token)
                        
                        completion(.success(token))
                    } catch {
                        print(error)
                        completion(.failure(error))
                    }
                }
                
            }
            task.resume()
        }
}

