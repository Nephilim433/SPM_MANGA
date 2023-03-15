//
//  SettingsViewController.swift
//  SPM MANGA
//
//  Created by Nephilim  on 1/20/23.
//

import UIKit
import SnapKit

class SettingsViewController: UIViewController {
    
    lazy var closeButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Закрити", style: .plain, target: self, action: #selector(close))
        return button
    }()
    
    let directionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.text = "Напрямок прокручування: "
        return label
    }()
    
    lazy var clearDownload: UIButton = {
        let button = UIButton()
        button.setTitle("Clear Downloads", for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.link, for: .normal)
        button.addTarget(self, action: #selector(clearDataBase), for: .touchUpInside)
        button.tintColor = .label
        return button
    }()
    
    deinit {
        print("SettingsViewController deinit!")
    }
    
    let segmentedControl: UISegmentedControl = {
        let items = ["Left to right", "Up to down"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "swipe")
        return segmentedControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(directionLabel)
        view.addSubview(clearDownload)
        view.addSubview(segmentedControl)
        
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        navBar.backgroundColor = .clear
        navBar.barTintColor = .white
        view.addSubview(navBar)
        
        let navItem = UINavigationItem(title: "Налаштування")
        navItem.rightBarButtonItem = closeButtonItem
        navBar.items = [navItem]
    }
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func clearDataBase() {
        DataManager.shared.deleteAllMangas()
        DataManager.shared.clearCache()
        setClearCacheButtonTitle()
        let alert = UIAlertController(title: "Завантажене та кєш видалині", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupViews()
    }
    
    @objc func segmentDidChange(_ segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            //"Left to right"
            UserDefaults.standard.set(0, forKey: "swipe")
        case 1:
            //"Up to down"
            UserDefaults.standard.set(1, forKey: "swipe")
        default:
            break
        }
    }
    private func setupViews() {
        directionLabel.frame = CGRect(x: 20, y: 100, width: view.width-40, height: 20)
        segmentedControl.frame = CGRect(x: 20, y: directionLabel.bottom+20, width: view.width-40, height: 55)
        clearDownload.frame = CGRect(x: 40, y: segmentedControl.bottom+20, width: view.width-80, height: 20)
        setClearCacheButtonTitle()
    }
    
    private func setClearCacheButtonTitle() {
        let title = "Очистити папку Завантажене та видалити кєш (\(DataManager.shared.howMuchCache()) мб)"
        clearDownload.setTitle(title, for: .normal)
    }
}
