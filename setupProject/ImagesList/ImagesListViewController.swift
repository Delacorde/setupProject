import UIKit
import Kingfisher
final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    
    private var imageListService = ImageListService.shared
    private var photos: [Photo] = []
    private var imageListServiceObs: NSObjectProtocol?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        imageListServiceObs = NotificationCenter.default.addObserver(forName: ImageListService.didChangeNotification, object: nil, queue: .main)
        { [weak self] _ in
            guard let self = self else { return }
            self.updateTableViewAnimated()
        }
        imageListService.fetchPhotosNextPage()
    }
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier{
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            let photo = photos[indexPath.row]
            if let fullImageURL = URL(string: photo.largeImageURL) {
                viewController.fullImageURL = fullImageURL
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
    
extension ImagesListViewController{
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath){
        let photo = photos[indexPath.row]
        cell.setIsLiked(photo.isLiked)
        if let createdAt = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = ""
        }
        
        let likeImage = photo.isLiked ? UIImage(named: "like") : UIImage(named: "noLike")
        cell.likeButton.setImage(likeImage, for: .normal)
        
        guard let url = URL(string: photo.thumbImageURL) else { return }
        
        cell.cellImage.kf.indicatorType = .activity
        
        
        let placeholder = UIImage(named: "placeholder")
        
        cell.cellImage.kf.setImage(
            with: url,
            placeholder: placeholder
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                break
            case .failure(let error):
                print("[ImagesListViewController.configCell]: Ошибка загрузки фото: \(error)")
            }
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imageListService.fetchPhotosNextPage()
        }
    }
    private func showLikeAlertError(){
        let alert = UIAlertController(title: "Что то пошло не так", message: "не удалось поставить лайк. Попробуйте еще раз", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
}
extension ImagesListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else{
            return UITableViewCell()
        }
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
        
    }
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}
extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.photos = self.imageListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print("[ImagesListViewController]: Ошибка лайка \(error)")
                self.showLikeAlertError()
            }
        }
    }
}
