//
//  InfoViewController.swift
//  SPM MANGA
//
//  Created by Nephilim  on 1/20/23.
//

import UIKit
import SDWebImage
import CoreData

class InfoViewController: UIViewController {


    let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)


    }


    @objc func clearDatabase() {


    }



    @objc func didTapClearDisk() {



        print("disk is cleared")
    }


}
