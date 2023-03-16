import UIKit

class FavoritesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    private var models: [MangaDetailModel]?

    let dummyLabel: UILabel = {
        let label = UILabel()
        label.text = "No Favorites yet.."
        label.font = .systemFont(ofSize: 27, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        navigationController?.navigationBar.tintColor = .label
        collectionView.register(MainMenuCell.self, forCellWithReuseIdentifier: MainMenuCell.identifier)

        view.addSubview(dummyLabel)
        dummyLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        dummyLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        navigationItem.title = "Вподобане"
        fetchFavorites()
    }

    private func fetchFavorites() {
        let favorites = DataManager.shared.getFavoriteMangas()
        if favorites.isEmpty {
            models = []
            self.collectionView.reloadData()
            // show "no favorites yet..." view
            print("dummy vie is showing")
            dummyLabel.isHidden = false

        } else {
            dummyLabel.isHidden = true
            DatabaseCaller.shared.getFavorites(for: favorites) { models in
                self.models = models
                self.collectionView.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        fetchFavorites()
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
            let vc = ChaptersListController(model: manga)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
