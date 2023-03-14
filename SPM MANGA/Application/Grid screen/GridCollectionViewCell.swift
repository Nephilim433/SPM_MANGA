//
//  GridCollectionViewCell.swift
//  MangaReader
//
//  Created by Nephilim  on 1/12/23.
//

import UIKit
//import FirebaseUI
import FirebaseStorage
import FirebaseStorageUI

class GridCollectionViewCell: UICollectionViewCell {
    static let identifier = "GridCollectionViewCell"
    let imageView = UIImageView()

    let posLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(posLabel)
        setupImageView()
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray

    }

    override func prepareForReuse() {
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
//        imageView.image = nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupImageView() {

        imageView.contentMode = .scaleAspectFit
        contentView.clipsToBounds = true

        posLabel.frame = CGRect(x: frame.width/2-8, y: frame.height-10, width: frame.width, height: 10)
        imageView.frame = CGRect(x: 0, y: 2, width: contentView.width, height: contentView.height-14)
    }

    public func configure(url: String, pos:Int, max:Int) {
        posLabel.text = "\(pos)/\(max)"
        if SDImageCache.shared.diskImageDataExists(withKey: url) {
            print("getting image from cache")
            SDImageCache.shared.queryImage(forKey: url, options: .highPriority, context: nil, cacheType: .disk) { image, data, cacheType in
                self.imageView.sd_imageIndicator = nil
                self.imageView.image = image
            }
        } else {
            print("loading image from Firebase")
            DataManager.shared.downloadImage(url) { imagee in
                self.imageView.image = imagee
            }
        }


//
//        let reference = Storage.storage().reference(forURL: url)
//        imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
//        imageView.sd_setImage(with: reference)
    }
    public func configure(key: String, pos:Int, max:Int) {
        posLabel.text = "\(pos)/\(max)"
        SDImageCache.shared.queryImage(forKey: key, options: .continueInBackground, context: nil, cacheType: .disk) { image, data, cacheType  in
//            print("key =",key)
//            print("cacheType =",cacheType)
//            print("data =",data)
            self.imageView.image = image

        }
    }
}
