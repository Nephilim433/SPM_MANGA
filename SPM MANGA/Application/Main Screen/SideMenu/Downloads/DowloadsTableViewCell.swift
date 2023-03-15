import UIKit
import SDWebImage

class DowloadsTableViewCell: UITableViewCell {
    static let identifier = "DowloadsTableViewCell"
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    let thumbnailImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "cover")
        return imageView
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.text = "no data?"
        label.numberOfLines = 3
        label.textAlignment = .left
        return label
    }()
    let chaptersCountLabel : UILabel = {
        let label = UILabel()
        label.text = "no data?"
        label.numberOfLines = 3
        return label
    }()
    
    let genrasLabel: UILabel = {
        let text = UILabel()
        text.text = "no data?"
        text.numberOfLines = 3
        text.font = UIFont.systemFont(ofSize: 14)
        return text
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(chaptersCountLabel)
        contentView.addSubview(genrasLabel)
        contentView.addSubview(separatorView)
    }
    
    
    override func layoutSubviews() {
        thumbnailImageView.frame = CGRect(x: 10, y: 5, width: (contentView.frame.size.width/3)-20, height: contentView.frame.size.height-10)
        titleLabel.frame = CGRect(x:thumbnailImageView.right+5, y: 5, width: contentView.width-thumbnailImageView.width-20, height: thumbnailImageView.height/2)
        titleLabel.sizeToFit()
        titleLabel.frame.size.width = contentView.width-thumbnailImageView.width-20
        chaptersCountLabel.frame = CGRect(x: titleLabel.left, y: titleLabel.bottom+5, width: titleLabel.width, height: 20)
        genrasLabel.frame = CGRect(x: chaptersCountLabel.left, y: chaptersCountLabel.bottom+5, width: titleLabel.width, height: thumbnailImageView.height-titleLabel.height-chaptersCountLabel.height-10)
        separatorView.frame = CGRect(x: 20, y: contentView.height-1, width: contentView.width-40, height: 1)
    }
    
    public func configure(with model: Manga) {
        SDImageCache.shared.queryImage(forKey: model.cover, options: .continueInBackground, context: nil, cacheType: .all) { image, data, cacheType  in
            self.thumbnailImageView.image = image
        }
        titleLabel.text = model.title
        chaptersCountLabel.text = "Розділів: \(String(model.chaptersCount))"
        genrasLabel.text = model.genras
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}










