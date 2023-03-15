import UIKit
import SDWebImage

class DownloadsViewController: UIViewController {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(DowloadsTableViewCell.self, forCellReuseIdentifier: DowloadsTableViewCell.identifier)
        return tableView
    }()
    var mangas = [Manga]()
    
    let dummyLabel: UILabel = {
        let label = UILabel()
        label.text = "Wow, such empty"
        label.font = .systemFont(ofSize: 27, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Завантажене"
        view.backgroundColor = .secondarySystemBackground
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        view.addSubview(dummyLabel)
        dummyLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        dummyLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        mangas = DataManager.shared.fetchMangas()
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height-view.safeAreaInsets.top)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showDummyLabel()
    }
    
    
    private func showDummyLabel() {
        print("mangas.count = \(mangas.count)")
        if mangas.count == 0 {
            dummyLabel.isHidden = false
        }
    }
    
    deinit {
        print("DownloadController deinit!")
    }
}

extension DownloadsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChaptersListController(model: mangas[indexPath.row])
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mangas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DowloadsTableViewCell.identifier, for: indexPath) as? DowloadsTableViewCell else { return UITableViewCell() }
        let model = mangas[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let swipeAction = UIContextualAction(style: .destructive, title: "Видалити") { action, sourceView, done in
            let model = self.mangas[indexPath.row]
            DataManager.shared.delete(manga: model)
            self.mangas.remove(at: indexPath.row)
            done(true)
            tableView.reloadData()
            self.showDummyLabel()
        }
        let swiperConfig = UISwipeActionsConfiguration(actions: [swipeAction])
        swiperConfig.performsFirstActionWithFullSwipe = true
        return swiperConfig
    }
}

