import UIKit
import SnapKit

class ChaptersListTableViewCell: UITableViewCell {

    static let indentifier = "ChaptersListTableViewCell"
    var isDownloading: Bool = false {
        didSet {
            isDownloading ? spinner.startAnimating() : spinner.stopAnimating()
        }
    }
    let spinner : UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.isHidden = false
        spinner.hidesWhenStopped = true
        return spinner
    }()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(spinner)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        spinner.frame = CGRect(x: contentView.width-contentView.height, y: 0, width: contentView.height, height: contentView.height)
    }
    private func setupViews() {
        let width = self.width-44
        spinner.snp.makeConstraints { make in
            make.centerX.equalTo(width)
        }
    }
}
