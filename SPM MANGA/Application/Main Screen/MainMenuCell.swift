import Foundation
import UIKit
import FirebaseStorageUI
import FirebaseStorage
import SnapKit

class MainMenuCell: UICollectionViewCell {
    static let identifier = "MainMenuCell"

    let thumbnailImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.myPink.cgColor
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "cover")
        imageView.layer.cornerRadius = 25

        return imageView
    }()

    let titleLabel : UILabel = {
        let label = UILabel()
        label.text = "no data?"
        label.font = .boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.textAlignment = .left

        return label
    }()
    let chaptersCountLabel : UILabel = {
        let label = UILabel()
        label.text = "no data?"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    let genrasLabel: UILabel = {
        let text = UILabel()
        text.text = "no data?"
        text.numberOfLines = 3
        text.font = UIFont.systemFont(ofSize: 14)

        return text
    }()

    let statusLabel: UILabel = {
        let text = UILabel()
        text.text = "no data?"
        text.numberOfLines = 2
        text.font = UIFont.systemFont(ofSize: 14)
        return text
    }()

    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .myPink
        return view
    }()

    lazy var grayView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemFill
        view.layer.cornerRadius = 25
        view.clipsToBounds = true
        return view
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(chaptersCountLabel)
        contentView.addSubview(genrasLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(separatorView)
        setupViews()
    }

    private func setupViews() {
        let imageWidth = ((contentView.height-10)/3)*2
        thumbnailImageView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(imageWidth)
        }

        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(thumbnailImageView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        statusLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp_bottomMargin).offset(20)
        }
        chaptersCountLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(statusLabel.snp_bottomMargin).offset(10)
        }

        genrasLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(chaptersCountLabel.snp_bottomMargin).offset(10)
            make.bottom.equalTo(separatorView.snp_topMargin)
        }
    }

    public func configure(with model: MangaDetailModel) {
        let reference = Storage.storage().reference(forURL: model.coverURL)
        thumbnailImageView.sd_setImage(with: reference)

        titleLabel.text = model.title

        let released = model.isFinished ? "випуск закінченний" : "випуск триває"
        let translated = model.isTranslated ? "переклад закінченний" : "переклад триває"
        
        statusLabel.text = "\(released)\n\(translated)"
        chaptersCountLabel.text = "Розділів: \(String(model.chaptersCount))"
        genrasLabel.text = model.genras
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

