import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var imageCellOutlet: UIImageView!
    @IBOutlet weak var dateLabelOutlet: UILabel!
    @IBOutlet weak var LikeButtonOutlet: UIButton!
}
