import Foundation

struct ProfileResult: Codable{
    let username: String
    let first_name: String
    let last_name: String?
    let bio: String?
}
struct Profile: Codable{
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}
final class ProfileService{
    static let shared = ProfileService()
    private init() {}
    
    //MARK: Properties
    private var task:URLSessionTask?
    private let urlSession = URLSession.shared
    private(set) var profile: Profile?
    
    //MARK: Funcs
    func fetchProfile(_ token: String, completion: @escaping(Result<Profile,Error>) -> Void){
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        let task = urlSession.objectTask(
            for: request
        ) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
                
            case .success(let profileResult):
                            let fullName = [profileResult.first_name, profileResult.last_name]
                                .compactMap { $0 }
                                .joined(separator: " ")
                            
                            let profile = Profile(
                                username: profileResult.username,
                                name: fullName,
                                loginName: "@\(profileResult.username)",
                                bio: profileResult.bio
                )
                self?.profile = profile
                completion(.success(profile))
                
            case .failure(let error):
                print("[ProfileService.fetchProfile]: \(error)")
                completion(.failure(error))
            }
            
            self?.task = nil
        }
        self.task = task
        task.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
