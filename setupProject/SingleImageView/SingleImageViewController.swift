import UIKit
import Kingfisher
final class SingleImageViewController: UIViewController {
    //MARK: Properties
    var fullImageURL: URL?
    // MARK: Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var didTapBackButton: UIButton!
    @IBOutlet weak var didTapShareButton: UIButton!
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        downloadFullImage()
        
    }
    //MARK: funcs
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    private func downloadFullImage() {
            guard let fullImageURL = fullImageURL else { return }
            
            UIBlockingProgressHUD.show()
            
            imageView.kf.setImage(with: fullImageURL) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                
                guard let self = self else { return }
                
                switch result {
                case .success(let imageResult):
                    self.image = imageResult.image
                case .failure(let error):
                    print("[SingleImageViewController.downloadFullImage]: Ошибка загрузки полноразмерного фото: \(error)")
                    self.showErrorAlert()
                }
            }
        }
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.downloadFullImage()
        }
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel)
        
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        
        present(alert, animated: true)
    }
    // MARK: Actions
    
    @IBAction func didTapBackButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = image else{return}
        let activityToShare: [Any] = [image]
        let activityController = UIActivityViewController(activityItems: activityToShare, applicationActivities: nil)
        
        present(activityController,animated: true)
    }
    
}
//MARK: Extensions
extension SingleImageViewController: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView)->UIView? {
        imageView
    }
}
