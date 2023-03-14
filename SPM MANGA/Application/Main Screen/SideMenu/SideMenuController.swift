//
//  SideMenuViewController.swift
//  SPM MANGA
//
//  Created by Nephilim  on 1/19/23.
//

import UIKit
import SideMenu

protocol SideMenuControllerDelegate {
    func didSelectMenu(item: SideMenuItem)
}
//MARK: - add later "Downloads" , Favorites,
enum SideMenuItem: String, CaseIterable {
    case home = "Головна сторінка"
    case favorites = "Вподобане"
    case downloads = "Завантажене"
    case info = "Зворотній зв'язок"
//    case settings = "Settings"

    var imageName: String {
        switch self {
        case .home:
//            return "house.circle.fill"
            return "house"
        case .favorites:
//            return "heart.circle.fill"
            return "heart.fill"
        case .downloads:
//            return "folder.circle.fill"
            return "folder"
        case .info:
//            return "info.circle.fill"
            return "info.circle"
//        case .settings:
//            return "gearshape.circle.fill"
        }
    }

}

class SideMenuController: UITableViewController {

    private let menuItems: [SideMenuItem]
    var delegate: SideMenuControllerDelegate?

    init(with menuItems: [SideMenuItem]) {
        self.menuItems = menuItems
        super.init(nibName: nil, bundle: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")


    }



    @objc func openSettings() {
        print("opening settings")
        let vc = SettingsViewController()
        vc.modalPresentationStyle = .formSheet
//        navigationController?.pushViewController(vc, animated: true)
        self.present(vc, animated: true, completion: nil)

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
//        tableView.backgroundColor = ColorHex.hexStringToUIColor(hex: HexColor.customGray.rawValue)
        tableView.isScrollEnabled = false
        
        let gearButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(openSettings))
        gearButton.tintColor = .label
        navigationItem.rightBarButtonItem = gearButton


        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //Relay to delegate about menu item selection
        let selectedItem = menuItems[indexPath.row]
        delegate?.didSelectMenu(item: selectedItem)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.contentView.backgroundColor = .secondarySystemBackground
        cell.backgroundColor = .secondarySystemBackground
//        cell.backgroundColor = ColorHex.hexStringToUIColor(hex: HexColor.customGray.rawValue)
        let image = UIImage(systemName: menuItems[indexPath.row].imageName)
        cell.imageView?.image = image
        cell.textLabel?.text = menuItems[indexPath.row].rawValue
        cell.textLabel?.textColor = .label
        cell.textLabel?.numberOfLines = 2
//        ColorHex.hexStringToUIColor(hex: HexColor.pinkishColor.rawValue)
        if cell.textLabel?.text == "Вподобане" {
        cell.tintColor = ColorHex.hexStringToUIColor(hex: HexColor.pinkishColor.rawValue)
        } else {
            cell.tintColor = .label
        }
        return cell
    }


}
