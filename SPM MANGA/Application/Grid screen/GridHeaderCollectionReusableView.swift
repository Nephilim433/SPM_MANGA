import UIKit

class GridHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "GridHeaderCollectionReusableView"

    private let chapterNameLabel: UILabel = {
        let label = UILabel()
        label.text = "🍣"

        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ColorHex.hexStringToUIColor(hex: HexColor.pinkishColor.rawValue).withAlphaComponent(0.5)
        addSubview(chapterNameLabel)
    }

    public func configure(chapterName: String) {
        chapterNameLabel.text = chapterName.replacingOccurrences(of: "_", with: " ")
    }
    override func layoutSubviews() {
        chapterNameLabel.frame = CGRect(x: 10, y: 2, width: frame.width-20, height: frame.height-4)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
