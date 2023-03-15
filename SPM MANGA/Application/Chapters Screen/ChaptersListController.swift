import Foundation
import UIKit
import FirebaseStorageUI
import FirebaseStorage

extension Notification.Name {
    static var downloadSuccess: Notification.Name {
        return .init(rawValue: "downloadSuccess")
    }
    static var downloadedAlready: Notification.Name {
        return .init(rawValue: "downloadedAlready")
    }
}

class ChaptersListController: UITableViewController {
    
    var model: MangaDetailModel?
    var cdmodel: Manga?
    var chapters : [Chapter]!
    
    var isExpanded = false {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.tableView.beginUpdates()
                self.changeHeaderHeight()
                self.tableView.endUpdates()
            }
            
        }
    }
    
    var headerHeight: CGFloat {
        let text = cdmodel?.descript != nil ? cdmodel?.descript : model?.description
        let textsize = DynamicLableSize.heightForZeroLines(text: text, font: .systemFont(ofSize: 14), width: view.width-20)
        
        //MARK: - Change here if you move descript label
        let sizeOfSmalltext:CGFloat = 53
        let expandedSize = 300+(textsize-sizeOfSmalltext)
        guard expandedSize > 300 else { return 300 }
        return isExpanded ? expandedSize : 300
    }
    
    init(model: MangaDetailModel) {
        self.model = model
        if let chapters = model.chapters {
            self.chapters = chapters.sorted { $0.chapterName.compare($1.chapterName , options: .numeric) == .orderedDescending }
        }
        super.init(nibName: nil, bundle: nil)
    }
    init(model: Manga) {
        self.cdmodel = model
        
        let cdchapters = model.chapters?.array as! [ChapterCD]
        let chapters: [Chapter] = cdchapters.compactMap({ chapterCD in
            let pages = chapterCD.pages?.array as! [PageCD]
            var mangaPages = pages.compactMap { MangaPage(orderIndex: Int($0.orderIndex!)!, url: $0.url!) }
            mangaPages = mangaPages.sorted { $0.orderIndex < $1.orderIndex }
            return Chapter(chapterName: chapterCD.chapterName!, chapterID: chapterCD.chapterID!, pages: mangaPages)
        })
        self.chapters = chapters.sorted { $0.chapterName.compare($1.chapterName , options: .numeric) == .orderedDescending }
        
        
        chapters.forEach { ch in
            print(ch.chapterName)
        }
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private let notificationCenter = NotificationCenter.default
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ChaptersHeaderView.self, forHeaderFooterViewReuseIdentifier: ChaptersHeaderView.identifier)
        tableView.register(ChaptersListTableViewCell.self, forCellReuseIdentifier: ChaptersListTableViewCell.indentifier)
        
        tableView.isScrollEnabled = true
        setupHeader()
        
        view.addSubview(spinner)
        notificationCenter.addObserver(self, selector: #selector(downloadedNotify), name: .downloadSuccess, object: nil)
        notificationCenter.addObserver(self, selector: #selector(downloadedAlready), name: .downloadedAlready, object: nil)
    }
    deinit {
        print("ChaptersListController deinit!")
        notificationCenter.removeObserver(self, name: .downloadedAlready, object: nil)
        notificationCenter.removeObserver(self, name: .downloadSuccess, object: nil)
    }
    
    lazy var spinner: UIActivityIndicatorView = {
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        
        let spinner = UIActivityIndicatorView(frame: CGRect(x: w/2, y: h/2, width: 50, height: 50))
        spinner.center = CGPoint(x: w/2, y: h/2)
        spinner.hidesWhenStopped = true
        spinner.isHidden = true
        return spinner
    }()
    
    
    @objc private func downloadedAlready() {
        spinner.stopAnimating()
        let alert = UIAlertController(title: "Whoops!", message: "Здається, ви вже маєте копію усіх розділів цієї манги на своєму телефоні", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    
    @objc private func downloadedNotify() {
        
        let visibleRect = CGRect(origin: self.tableView.contentOffset, size: self.tableView.bounds.size)
        let tempView = UIView(frame: visibleRect)
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.square"))
        tempView.addSubview(imageView)
        imageView.frame = CGRect(x: tempView.width/2-50, y: tempView.height/2-50, width: 100, height: 100)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = ColorHex.hexStringToUIColor(hex: HexColor.pinkishColor.rawValue)
        tableView.addSubview(tempView)
        tempView.alpha = 1.0
        tempView.isHidden = false
        spinner.stopAnimating()
        
        UIView.animate(withDuration: 1.0) {
            tempView.alpha = 0.0
        } completion: { done in
            if done {
                
                self.tableView.reloadData()
                tempView.isHidden = true
            }
        }
        print("Finished downloading!")
    }
    
    private func changeHeaderHeight() {
        header?.frame = CGRect(x: 0, y: 0, width: view.width, height: headerHeight)
    }
    var header : ChaptersHeaderView?
    private func setupHeader() {
        header = ChaptersHeaderView(frame: CGRect(x: 0, y: 0, width: view.width, height: headerHeight))
        tableView.tableHeaderView = header
        
        if let cdmodel = cdmodel {
            let model = MangaDetailModel(title: cdmodel.title!, coverURL: cdmodel.cover!, chaptersCount: Int(cdmodel.chaptersCount), volumesCount: Int(cdmodel.volumesCount), genras: cdmodel.genras!, description: cdmodel.descript!, directory: cdmodel.directory!, chapters: nil, author: cdmodel.author!, status: cdmodel.status!, translation: cdmodel.translation!, release: Int(cdmodel.releaseYear), isTranslated: cdmodel.isTranslated, isFinished: cdmodel.isFinished)
            header?.configure(with: model)
        } else {
            guard let model = model else {
                return
            }
            header?.configure(with: model)
        }
        header?.delegate = self
    }
}

//MARK: - Tableview datasource and delegate methods
extension ChaptersListController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let index = chapters.count - indexPath.row-1
        let title = (cdmodel?.title != nil ? cdmodel?.title : model?.title)!
        let vc = GridViewController(chapters: chapters, title: title, index: index)
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chapters?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChaptersListTableViewCell.indentifier, for: indexPath) as? ChaptersListTableViewCell else { return UITableViewCell() }
        cell.isDownloading = false
        if let chapter = chapters?[indexPath.row] {
            cell.textLabel?.text = chapter.chapterName.replacingOccurrences(of: "_", with: " ")
            cell.tintColor = ColorHex.hexStringToUIColor(hex: HexColor.pinkishColor.rawValue)
            cell.accessoryType = DataManager.shared.existsChapter(with: chapter.chapterID) ? .checkmark : .none
        }
        cell.isDownloading = false
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let chapterToDownload = self.chapters?[indexPath.row], let model = self.model else {
            print("can't save...")
            return nil
        }
        let swipeAction = UIContextualAction(style: .normal, title: "") { action, sourceView, complition in
            var chaptersToSave = [Chapter]()
            chaptersToSave.append(chapterToDownload)
            print("save tapped")
            complition(true)
            DataManager.shared.saveChapter(for: model, with: chaptersToSave)
            guard let cell = tableView.cellForRow(at: indexPath) as? ChaptersListTableViewCell else { return }
            cell.isDownloading = true
        }
        let config = UIImage.SymbolConfiguration(pointSize: 16)
        let image = UIImage(systemName: "arrow.down", withConfiguration: config)
        swipeAction.image = image
        
        let swiperConfig = DataManager.shared.existsChapter(with: chapterToDownload.chapterID) ? UISwipeActionsConfiguration() : UISwipeActionsConfiguration(actions: [swipeAction])
        let anotherSwipeConfig = UISwipeActionsConfiguration()
        
        swiperConfig.performsFirstActionWithFullSwipe = true
        
        return cdmodel == nil ? swiperConfig : anotherSwipeConfig
    }
    
}


extension ChaptersListController: ChaptersHeaderViewDelegate {
    func downloadThisManga() {
        print("I want to download all chapters")
        guard model != nil else {
            return
        }
        let alert = UIAlertController(title: "Ви дійсно хочете завантажити всі розділи?", message: "Це може займати багато пам'яті вашого телефону", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Завантажити", style: .default, handler: { action in
            print("beep boop downloading")
            self.spinner.isHidden = false
            self.spinner.startAnimating()
            DataManager.shared.saveManga(model: self.model!) 
        }))
        alert.addAction(UIAlertAction(title: "Скасувати", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func readThisManga() {
        let title = (cdmodel?.title != nil ? cdmodel?.title : model?.title)!
        let vc = GridViewController(chapters: chapters, title: title)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func favoriteThisManga() {
        guard let title = model?.directory else { return }
        DataManager.shared.favoriteManga(with: title)
    }
    
    func unfavoriteThisManga() {
        guard let title = model?.directory else { return }
        DataManager.shared.unfavoriteManga(with: title)
    }
    
    func didTapToggleHeaderViewHeight() {
        print("didTapToggleHeaderViewHeight executed")
        self.isExpanded.toggle()
        print("isExpanded = \(isExpanded)")
    }
}
