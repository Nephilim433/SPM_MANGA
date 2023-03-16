import UIKit

class SwipingController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var chapters = [Chapter]()

    var callback: ((Int) -> Void)?
    var indexPath: IndexPath?
    var fullScreenLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        if UserDefaults.standard.integer(forKey: "swipe") == 0 {
            layout.scrollDirection = .horizontal
        } else {
            layout.scrollDirection = .vertical
        }
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        return layout
    }()

    init(chapters: [Chapter], indexPath: IndexPath) {
        self.chapters = chapters
        self.indexPath = indexPath
        super.init(collectionViewLayout: fullScreenLayout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("SwipingController deinit!")
    }

    var hideStatusBar: Bool = true {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    override var prefersStatusBarHidden: Bool {
        return hideStatusBar
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.prefersLargeTitles = false

        navigationController?.isNavigationBarHidden.toggle()
        collectionView.contentInsetAdjustmentBehavior = .never

        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(FullScreenCollectionViewCell.self, forCellWithReuseIdentifier: FullScreenCollectionViewCell.identifier)
        collectionView.isPagingEnabled = true
        scrollToRightPage()
    }

    private func scrollToRightPage() {
        self.collectionView?.isPagingEnabled = false
        self.collectionView?.scrollToItem(at: self.indexPath!, at: [ .centeredHorizontally, .centeredVertically], animated: false)
        self.collectionView?.setNeedsLayout()
        self.collectionView?.layoutSubviews()
        self.collectionView?.isPagingEnabled = true
    }

    // MARK: - Cell for Item At
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FullScreenCollectionViewCell.identifier, for: indexPath) as? FullScreenCollectionViewCell else {
            return UICollectionViewCell()
        }

        let url = chapters[indexPath.section].pages[indexPath.item].url
        print(url)
        print(chapters[indexPath.section].pages[indexPath.item].orderIndex)
        cell.delegate = self
        cell.configure(url: url)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chapters[section].pages.count
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return chapters.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        callback?(indexPath.section)
        self.indexPath = indexPath
        let chapter = chapters[indexPath.section]
        let chaptersName = chapter.chapterName, chaptersCount = chapter.pages.count

        let label = UILabel()
        label.numberOfLines = 2
        label.sizeToFit()
        label.textAlignment = .center
        label.textColor = .myPink
        let text = "\(chaptersName)\n\(indexPath.item+1)/\(chaptersCount)"
        label.text = text.replacingOccurrences(of: "_", with: " ")
        self.navigationItem.titleView = label
    }
}

extension SwipingController: FullScreenCollectionViewCellDelegate {
    func didTapFullScreenCell() {
        print("didTapFullScreenCell executed")
        UIView.animate(withDuration: 0.3) {
            self.hideStatusBar.toggle()
            self.navigationController?.isNavigationBarHidden.toggle()
        }
    }
}
