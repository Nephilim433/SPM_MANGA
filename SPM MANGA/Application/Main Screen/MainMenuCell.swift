//
//  MainMenuCell.swift
//  SPM MANGA
//
//  Created by Nephilim  on 1/19/23.
//

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
        //was
        imageView.contentMode = .scaleAspectFill
        //test
//        imageView.contentMode = .scaleAspectFit
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
//        label.backgroundColor = .purple
        label.numberOfLines = 0
        label.textAlignment = .left

        return label
    }()
    let chaptersCountLabel : UILabel = {
        let label = UILabel()
        label.text = "no data?"
        label.font = UIFont.systemFont(ofSize: 14)
//        label.backgroundColor = .red
//        label.numberOfLines = 3

        return label
    }()

    let genrasLabel: UILabel = {
        let text = UILabel()
        text.text = "no data?"
//        text.backgroundColor = .red
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
//        view.backgroundColor = .label
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
//        contentView.addSubview(grayView)
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
//            make.left.equalTo(thumbnailImageView.snp.right).offset(20)
            make.right.equalToSuperview().offset(-10)
//            make.right.equalToSuperview().offset(-20)
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

//        grayView.snp.makeConstraints { make in
//            make.bottom.right.equalToSuperview().offset(-10)
//            make.top.equalToSuperview().offset(10)
////            make.left.equalTo(thumbnailImageView.right).offset(10)
//            make.left.equalTo(thumbnailImageView.snp.right).offset(10)
//        }
    }

//    override func layoutSubviews() {
//        super.layoutSubviews()
//        let oldImageWidth = (contentView.frame.size.width/3)-20
//        let oldImageHeight = contentView.frame.size.height-10
//        let imageWidth = ((contentView.height-10)/3)*2
//        thumbnailImageView.frame = CGRect(x: 10, y: 5, width: imageWidth, height: contentView.frame.size.height-10)
//        titleLabel.frame = CGRect(x:thumbnailImageView.right+5, y: 5, width: contentView.width-thumbnailImageView.width-20, height: thumbnailImageView.height/2)
//        titleLabel.sizeToFit()
//        titleLabel.frame.size.width = contentView.width-thumbnailImageView.width-20
//        chaptersCountLabel.frame = CGRect(x: titleLabel.left, y: titleLabel.bottom+5, width: titleLabel.width, height: 20)
//        genrasLabel.frame = CGRect(x: chaptersCountLabel.left, y: chaptersCountLabel.bottom+5, width: titleLabel.width, height: thumbnailImageView.height-titleLabel.height-chaptersCountLabel.height-10)
//        separatorView.frame = CGRect(x: 10, y: contentView.height-1, width: contentView.width-20, height: 1)
//    }

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




//
//extension UIView {
//    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
//        translatesAutoresizingMaskIntoConstraints = false
//
//        if let top = top {
//            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
//        }
//        if let leading = leading {
//            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
//        }
//        if let bottom = bottom {
//            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
//        }
//        if let trailing = trailing {
//            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
//        }
//
//
//        if size.width != 0 {
//                widthAnchor.constraint(equalToConstant: size.width).isActive = true
//        }
//        if size.height != 0 {
//                heightAnchor.constraint(equalToConstant: size.height).isActive = true
//        }
//
//    }
//}


