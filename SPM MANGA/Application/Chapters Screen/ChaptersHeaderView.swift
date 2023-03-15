import UIKit
import FirebaseStorageUI
import FirebaseStorage
import SnapKit

protocol ChaptersHeaderViewDelegate:AnyObject {
    func didTapToggleHeaderViewHeight()
    func favoriteThisManga()
    func unfavoriteThisManga()
    func downloadThisManga()
    func readThisManga()
}


class ChaptersHeaderView: UITableViewHeaderFooterView {
    static let identifier = "ChaptersHeaderView"
    static let buttonSize = 30


    weak var delegate: ChaptersHeaderViewDelegate?
    var isFavorite = false
    let titleLabel : UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let volumesLabel: UILabel = {
        let text = UILabel()
        text.numberOfLines = 0
        text.font = UIFont.systemFont(ofSize: 14)
        text.isUserInteractionEnabled = true
        return text
    }()

    let chaptersLabel: UILabel = {
        let text = UILabel()
        text.numberOfLines = 1
        text.font = UIFont.systemFont(ofSize: 14)
        text.isUserInteractionEnabled = true
        return text
    }()

    let authorLabel: UILabel = {
        let text = UILabel()
        text.lineBreakMode = .byTruncatingTail
        text.numberOfLines = 1
        text.font = UIFont.systemFont(ofSize: 14)
        return text
    }()

    let translationLabel: UILabel = {
        let text = UILabel()
        text.lineBreakMode = .byTruncatingTail
        text.numberOfLines = 0
        text.font = UIFont.systemFont(ofSize: 14)
        return text
    }()
    let genrasLabel: UILabel = {
        let text = UILabel()
        text.numberOfLines = 2
        text.font = UIFont.systemFont(ofSize: 14)
        return text
    }()
    let releaseYear: UILabel = {
        let text = UILabel()
        text.numberOfLines = 1
        text.font = UIFont.systemFont(ofSize: 14)
        return text
    }()
    let descriptionLabel: UILabel = {
        let text = UILabel()
        text.numberOfLines = 0
        text.font = UIFont.systemFont(ofSize: 14)
        text.isUserInteractionEnabled = true
        return text
    }()

    var thumbnailImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let favoriteButton: UIButton = {
        let button = UIButton()
        button.tintColor = ColorHex.hexStringToUIColor(hex: HexColor.pinkishColor.rawValue)
        button.addTarget(self, action: #selector(toggleFavoriteButton), for: .touchUpInside)
        return button
    }()
    let downloadAllButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let config = UIImage.SymbolConfiguration(pointSize: 27)
        button.setImage(UIImage(systemName: "arrow.down.square", withConfiguration: config), for: .normal)
        let imagee = UIImage(systemName: "arrow.down.square")
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(downloadButtonPressed), for: .touchUpInside)
        return button
    }()
    let startToReadButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let config = UIImage.SymbolConfiguration(pointSize: 27)
        button.setImage(UIImage(systemName: "eye", withConfiguration: config), for: .normal)
        button.addTarget(self, action: #selector(startToReadButtonPressed), for: .touchUpInside)
        return button
    }()

    var favoriteImage : UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "heart" + (isFavorite ? ".fill" : ""), withConfiguration: config)!
        return image
    }

    lazy var grayView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemFill
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()


    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.isUserInteractionEnabled = true
        backgroundColor = .gray
        addSubview(grayView)
        addSubview(genrasLabel)
        addSubview(releaseYear)
        addSubview(translationLabel)
        addSubview(authorLabel)
        addSubview(chaptersLabel)
        addSubview(volumesLabel)
        addSubview(thumbnailImageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(favoriteButton)
        addSubview(startToReadButton)
        addSubview(downloadAllButton)

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleHeaderViewHeight))
        tap.numberOfTapsRequired = 1
        descriptionLabel.addGestureRecognizer(tap)

        setupConstraints()
    }


    @objc func toggleFavoriteButton() {
        favoriteButton.pressAnimation()
        if isFavorite {
            delegate?.unfavoriteThisManga()
        } else {
            delegate?.favoriteThisManga()
        }
        isFavorite = !isFavorite
        favoriteButton.setImage(favoriteImage, for: .normal)
    }

    @objc func toggleHeaderViewHeight() {
        delegate?.didTapToggleHeaderViewHeight()
    }


    @objc func downloadButtonPressed() {
        downloadAllButton.pressAnimation()
        delegate?.downloadThisManga()
    }


    @objc func startToReadButtonPressed() {
        startToReadButton.pressAnimation()
        delegate?.readThisManga()
    }


    private func setupConstraints() {
        thumbnailImageView.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(150)
            make.left.top.equalToSuperview().offset(10)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(thumbnailImageView.snp.right).offset(10)
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        ///putting labels from down to top, constaining it to bottom of imageview

        //(translationLabel)
        translationLabel.snp.makeConstraints { make in
            make.bottom.equalTo(thumbnailImageView.snp.bottom)
            make.right.equalToSuperview().offset(-10)
            make.left.equalTo(thumbnailImageView.snp.right).offset(10)
        }
        //(authorLabel)
        authorLabel.snp.makeConstraints { make in
            make.bottom.equalTo(translationLabel.snp.top).offset(-5)
            make.right.equalToSuperview().offset(-10)
            make.left.equalTo(thumbnailImageView.snp.right).offset(10)
        }
        //(chaptersLabel)
        chaptersLabel.snp.makeConstraints { make in
            make.bottom.equalTo(authorLabel.snp.top).offset(-5)
            make.right.equalToSuperview().offset(-10)
            make.left.equalTo(thumbnailImageView.snp.right).offset(10)
        }
        //(volumesLabel)
        volumesLabel.snp.makeConstraints { make in
            make.bottom.equalTo(chaptersLabel.snp.top).offset(-5)
            make.right.equalToSuperview().offset(-10)
            make.left.equalTo(thumbnailImageView.snp.right).offset(10)
        }
        //(releaseYear)
        releaseYear.snp.makeConstraints { make in
            make.bottom.equalTo(volumesLabel.snp.top).offset(-5)
            make.right.equalToSuperview().offset(-10)
            make.left.equalTo(thumbnailImageView.snp.right).offset(10)
        }

        ///butttons
        downloadAllButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(ChaptersHeaderView.buttonSize)
            make.width.equalTo(ChaptersHeaderView.buttonSize*2)
            make.bottom.equalToSuperview().offset(-10)

        }
        favoriteButton.snp.makeConstraints { make in
            make.left.equalTo(downloadAllButton.snp.right)
            make.height.equalTo(ChaptersHeaderView.buttonSize)
            make.width.equalTo(ChaptersHeaderView.buttonSize*2)
            make.bottom.equalTo(downloadAllButton.snp.bottom)
        }
        startToReadButton.snp.makeConstraints { make in
            make.right.equalTo(downloadAllButton.snp.left)
            make.height.equalTo(ChaptersHeaderView.buttonSize)
            make.width.equalTo(ChaptersHeaderView.buttonSize*2)
            make.bottom.equalTo(downloadAllButton.snp.bottom)
        }
        //(genrasLabel)
        genrasLabel.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)

        }
        //description
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(genrasLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalTo(downloadAllButton.snp.top).offset(-10)
        }
        //grayview
        grayView.snp.makeConstraints { make in
            make.left.top.equalTo(startToReadButton).offset(-5)
            make.right.bottom.equalTo(favoriteButton).offset(5)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(with model: MangaDetailModel) {

        if SDImageCache.shared.diskImageDataExists(withKey: model.coverURL) {
            SDImageCache.shared.queryImage(forKey: model.coverURL, options: .continueInBackground, context: nil, cacheType: .disk) { image, data, cacheType  in
                self.thumbnailImageView.image = image
            }
        } else {
            let reference = Storage.storage().reference(forURL: model.coverURL)
            thumbnailImageView.sd_setImage(with: reference)
        }
        descriptionLabel.text = model.description
        titleLabel.text = model.title
        isFavorite =  DataManager.shared.isFavorite(with: model.directory)
        favoriteButton.setImage(favoriteImage, for: .normal)
        print("isFavorite = \(isFavorite)")

        let released = model.isFinished ? "випуск закінченний" : "випуск триває"
        volumesLabel.text = "Томів: \(model.volumesCount), \(released)"
        let translated = model.isTranslated ? "переклад закінченний" : "переклад триває"
        chaptersLabel.text = "Розділів: \(model.chaptersCount), \(translated)"
        authorLabel.text = "Автор: \(model.author)"
        translationLabel.text = "Переклад: \(model.translation)"
        let release = model.release == 0 ? "-" : String(model.release)
        releaseYear.text = "Рік: \(release)"
        genrasLabel.text = "Жанр: \(model.genras)"
    }

}


extension UIButton {

    func pressAnimation() {

        let expandTransform:CGAffineTransform = CGAffineTransform(scaleX: 1.15, y: 1.15);
        UIView.transition(with: self,
                          duration:0.1,
                          options: UIView.AnimationOptions.transitionCrossDissolve,
                          animations: {
            self.transform = expandTransform
        },
                          completion: {(finished: Bool) in
            UIView.animate(withDuration: 0.4,
                           delay:0.0,
                           usingSpringWithDamping:0.40,
                           initialSpringVelocity:0.2,
                           options:UIView.AnimationOptions.curveEaseOut,
                           animations: {
                self.transform = .identity
            }, completion:nil)
        })
    }
}
