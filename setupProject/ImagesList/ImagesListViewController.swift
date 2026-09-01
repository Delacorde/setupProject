import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated(addedIndexes: [Int])
    func showLikeAlertError()
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    @IBOutlet private var tableView: UITableView!
    
    var presenter: ImagesListPresenterProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        if presenter == nil {
            let presenter = ImagesListPresenter()
            presenter.view = self
            self.presenter = presenter
        }
        
        presenter?.viewDidLoad()
    }
    
    let showSingleImageSegueIdentifier = "ShowSingleImage"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            guard let photo = presenter?.photo(at: indexPath.row),
                  let fullImageURL = URL(string: photo.largeImageURL) else { return }
            viewController.fullImageURL = fullImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    
    func updateTableViewAnimated(addedIndexes: [Int]) {
        let indexPaths = addedIndexes.map { IndexPath(row: $0, section: 0) }
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func showLikeAlertError() {
        let alert = UIAlertController(title: "Что то пошло не так", message: "не удалось поставить лайк. Попробуйте еще раз", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let photo = presenter?.photo(at: indexPath.row) else { return }
        
        configureCellDate(for: cell, with: photo.createdAt)
        configureCellLikeButton(for: cell, isLiked: photo.isLiked)
        configureCellImage(for: cell, with: photo.thumbImageURL)
    }
    
    func configureCellDate(for cell: ImagesListCell, with date: Date?) {
        if let date = date, let dateString = presenter?.formatDate(date) {
            cell.dateLabel.text = dateString
        } else {
            cell.dateLabel.text = ""
        }
    }
    
    func configureCellLikeButton(for cell: ImagesListCell, isLiked: Bool) {
        cell.setIsLiked(isLiked)
        let likeImage = isLiked ? UIImage(named: "like") : UIImage(named: "noLike")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    
    func configureCellImage(for cell: ImagesListCell, with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        cell.cellImage.kf.indicatorType = .activity
        let placeholder = UIImage(named: "placeholder")
        
        cell.cellImage.kf.setImage(
            with: url,
            placeholder: placeholder
        ) { result in
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
        
        guard let photo = presenter?.photo(at: indexPath.row) else { return 0 }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.fetchNextPageIfNeeded(forRowAt: indexPath.row)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.photosCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        UIBlockingProgressHUD.show()
        
        presenter?.changeLike(for: indexPath.row) { [weak self, weak cell] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self, let cell = cell else { return }
            
            switch result {
            case .success:
                if let updatedPhoto = self.presenter?.photo(at: indexPath.row) {
                    self.configureCellLikeButton(for: cell, isLiked: updatedPhoto.isLiked)
                }
            case .failure(let error):
                print("[ImagesListViewController]: Ошибка лайка \(error)")
                self.showLikeAlertError()
            }
        }
    }
}
