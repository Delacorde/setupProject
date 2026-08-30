import UIKit
import Kingfisher
protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    weak var delegate: ImagesListCellDelegate?
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    @IBAction private func likeButtonClicked(){
        delegate?.imageListCellDidTapLike(self)
    }
    func setIsLiked(_ isLiked: Bool){
        let likeImage = isLiked ? UIImage(named: "like") : UIImage(named: "noLike")
        likeButton.setImage(likeImage, for: .normal)
    }
    
}
