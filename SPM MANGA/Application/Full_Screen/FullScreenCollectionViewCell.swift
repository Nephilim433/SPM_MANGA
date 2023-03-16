import UIKit
import ImageScrollView
import FirebaseStorageUI
import FirebaseStorage

protocol FullScreenCollectionViewCellDelegate: AnyObject {
    func didTapFullScreenCell()
}

class FullScreenCollectionViewCell: UICollectionViewCell {
    static let identifier = "FullScreenCollectionViewCell"

    weak var delegate: FullScreenCollectionViewCellDelegate?
    let imageScrollView: ImageScrollView = {
        let view = ImageScrollView()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        imageScrollView.setup()
        contentView.addSubview(imageScrollView)
        setupImageScrollView()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        imageScrollView.addGestureRecognizer(tapGesture)
    }

    @objc func didTap() {
        delegate?.didTapFullScreenCell()
    }

    private func setupImageScrollView() {
        imageScrollView.frame = CGRect(x: 0, y: 0, width: contentView.width, height: contentView.height)
    }

    public func configure(url: String) {
        if SDImageCache.shared.diskImageDataExists(withKey: url) {
            let image = SDImageCache.shared.imageFromCache(forKey: url)!
            imageScrollView.display(image: image)
        } else {
            DataManager.shared.downloadImage(url) { [weak self] imagee in
                self?.imageScrollView.display(image: imagee)
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageScrollView.display(image: UIImage(named: "cover")!)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
