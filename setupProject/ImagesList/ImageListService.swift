import Foundation
import CoreGraphics

struct PhotoLikeResult: Codable {
    let photo: PhotoResult
}

final class ImageListService {
    //MARK: Properties
    static let shared = ImageListService()
    private init() {}
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private let isoDateFormatter = ISO8601DateFormatter()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    //MARK: Funcs
    func fetchPhotosNextPage(){
        assert(Thread.isMainThread)
        
        guard task == nil else {return}
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImagesListService.fetchPhotosNextPage]: AuthError - отсутствует токен авторизации")
            return
        }
        guard let request = makePhotosRequest(page: nextPage, token: token) else {
            print("[ImagesListService.fetchPhotosNextPage]: URLError - не удалось создать URLRequest для страницы: \(nextPage)")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let photoResults):
                    let newPhotos = photoResults.map { photoResult in
                        var date: Date?
                        if let dateString = photoResult.createdAt {
                            date = self.isoDateFormatter.date(from: dateString)
                        }
                        
                        return Photo(
                            id: photoResult.id,
                            size: CGSize(width: photoResult.width, height: photoResult.height),
                            createdAt: date,
                            welcomeDescription: photoResult.description,
                            thumbImageURL: photoResult.urls.thumb,
                            largeImageURL: photoResult.urls.full,
                            isLiked: photoResult.likedByUser
                        )
                    }
                    
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    
                    NotificationCenter.default.post(
                        name: ImageListService.didChangeNotification,
                        object: self
                    )
                    
                case .failure(let error):
                    print("[ImagesListService.fetchPhotosNextPage]: RequestError - \(error.localizedDescription), page: \(nextPage)")
                }
                
                self.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImagesListService.changeLike]: AuthError - отсутствует токен авторизации для photoId: \(photoId)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike, token: token) else {
            print("[ImagesListService.changeLike]: URLError - не удалось создать URLRequest для photoId: \(photoId)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<PhotoLikeResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success:
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: isLike
                        )
                        self.photos[index] = newPhoto
                    }
                    completion(.success(()))
                    
                case .failure(let error):
                    print("[ImagesListService.changeLike]: RequestError - \(error.localizedDescription), photoId: \(photoId), isLike: \(isLike)")
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func makePhotosRequest(page: Int, token: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else {
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = urlComponents.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
