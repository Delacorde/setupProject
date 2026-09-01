import Foundation
protocol ImagesListPresenterProtocol{
    var view: ImagesListViewControllerProtocol? { get set }
        var photosCount: Int { get }
        func viewDidLoad()
        func photo(at index: Int) -> Photo?
        func fetchNextPageIfNeeded(forRowAt index: Int)
        func formatDate(_ date: Date) -> String
        func changeLike(for index: Int, completion: @escaping (Result<Void, Error>) -> Void)
}

final class ImagesListPresenter: ImagesListPresenterProtocol{
    var view: ImagesListViewControllerProtocol?
    
    private let imageListService = ImageListService.shared
    private var photos: [Photo] = []
    private var imageListServiceObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    var photosCount: Int {
        return photos.count
    }
    
    func viewDidLoad() {
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImageListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.handlePhotosUpdate()
        }
        
        imageListService.fetchPhotosNextPage()
    }
    
    func photo(at index: Int) -> Photo? {
        guard index >= 0 && index < photos.count else { return nil }
        return photos[index]
    }
    
    func fetchNextPageIfNeeded(forRowAt index: Int) {
        if index + 1 == photos.count {
            imageListService.fetchPhotosNextPage()
        }
    }
    
    func formatDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func changeLike(for index: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let photo = photo(at: index) else { return }
        
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.photos = self.imageListService.photos
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func handlePhotosUpdate() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        
        if oldCount != newCount {
            let addedIndexes = Array(oldCount..<newCount)
            view?.updateTableViewAnimated(addedIndexes: addedIndexes)
        }
    }
}

