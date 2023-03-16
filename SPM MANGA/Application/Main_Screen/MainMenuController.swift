import UIKit
import FirebaseStorage
import Firebase
import SideMenu
import FirebaseStorageUI
import FirebaseDatabase

class MainMenuController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    private lazy var menuBarButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal"),
                                                     style: .done,
                                                     target: self,
                                                     action: #selector(didTapMenuBarButton))

    private let searchController: UISearchController = {
        let controller = UISearchController()
        return controller
    }()

    private var sideMenu: SideMenuNavigationController?

    private lazy var settingsController = SettingsViewController()
    private lazy var infoController = InfoViewController()

    private let storage = Storage.storage()
    private var ref = Database.database().reference()
    private var models: [MangaDetailModel]?

    init(collectionViewLayout layout: UICollectionViewLayout, models: [MangaDetailModel]) {
//        if models.count != 0 {
        if !models.isEmpty {
            self.models = models
        }
        super.init(collectionViewLayout: layout)
        fetchData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSideMenu()
        navigationItem.setLeftBarButton(menuBarButton, animated: false)
        navigationController?.navigationBar.tintColor = .label
        collectionView.backgroundColor = .systemBackground

        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self

        collectionView.register(MainMenuCell.self, forCellWithReuseIdentifier: MainMenuCell.identifier)
        addChildControllers()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh and randomize...")
        refreshControl.tintColor = ColorHex.hexStringToUIColor(hex: HexColor.pinkishColor.rawValue)
        collectionView.refreshControl = refreshControl
        collectionView.alwaysBounceVertical = true
        navigationItem.title = "Головна сторінка"
    }

    @objc func refresh(for control: UIRefreshControl) {
        fetchData()
        collectionView.reloadData()
        control.endRefreshing()
    }

    private func addChildControllers() {

        addChild(infoController)
        view.addSubview(infoController.view)
        infoController.view.frame = view.bounds

        infoController.didMove(toParent: self)

        infoController.view.isHidden = true

    }
    private func fetchData() {
        DatabaseCaller.shared.getMangaDetails { models in

            let shuffled = models.shuffled()
            self.models = shuffled

            self.collectionView.reloadData()
        }
    }

    private func setupSideMenu() {
        let menu = SideMenuController(with: SideMenuItem.allCases)
        menu.delegate = self
        sideMenu = SideMenuNavigationController(rootViewController: menu)
        sideMenu?.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)
    }
    @objc func didTapMenuBarButton() {
        // MARK: - show side menu
        guard let sideMenu = sideMenu else { return }
        present(sideMenu, animated: true, completion: nil)

    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainMenuCell.identifier, for: indexPath) as? MainMenuCell else { return UICollectionViewCell() }

        guard let model = models?[indexPath.item] else { return UICollectionViewCell() }

        cell.configure(with: model)

        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models?.count ?? 0

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = view.height / 4
        return CGSize(width: view.width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = models?[indexPath.row] else { return }
        DatabaseCaller.shared.getChapters(for: model) { manga in
            let chaptersVC = ChaptersListController(model: manga)
            self.navigationController?.pushViewController(chaptersVC, animated: true)

        }
    }

}

extension MainMenuController: SideMenuControllerDelegate {
    func didSelectMenu(item: SideMenuItem) {
        sideMenu?.dismiss(animated: true, completion: nil)
        // change controller
        switch item {
        case .home:
            settingsController.view.isHidden = true
            infoController.view.isHidden = true
            navigationItem.searchController = searchController
        case .info:
            settingsController.view.isHidden = true
            infoController.view.isHidden = false
            navigationItem.searchController = nil
        case .favorites:
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            let favoritesVC = FavoritesController(collectionViewLayout: layout)
            favoritesVC.modalPresentationStyle = .overFullScreen
            navigationController?.pushViewController(favoritesVC, animated: true)
        case .downloads:
            let downloadsVC = DownloadsViewController()
            navigationController?.pushViewController(downloadsVC, animated: true)
        }
    }
}

extension MainMenuController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //TODO: Change it search without button
        print("UpdateSearchResults")
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        guard let query = searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        print("query = \(query)")
        DatabaseCaller.shared.queryMangas(with: query) { mangaModels in
            self.models = mangaModels
            self.collectionView.reloadData()
            self.searchController.isActive = false

        }

    }
}
