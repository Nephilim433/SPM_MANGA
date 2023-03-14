//
//  GridViewController.swift
//  MangaReader
//
//  Created by Nephilim  on 1/13/23.
//

import UIKit


class GridViewController: UIViewController {


    var model: MangaDetailModel?
    
    var index: Int?
//    {
//        didSet {
//            print(index!)
//        }
//    }

    var cdmodel: Manga?

    var chapters = [Chapter]()
    var cdchapters = [ChapterCD]()

    var collectionView: UICollectionView?

    init(model : MangaDetailModel, index: Int) {
        self.model = model

        chapters = model.chapters!
        chapters = chapters.sorted { $0.chapterName.compare($1.chapterName , options: .numeric) == .orderedAscending }
        self.index = index
        print("index = \(index)")
        super.init(nibName: nil, bundle: nil)
    }
    init(model : MangaDetailModel) {
        self.model = model

        chapters = model.chapters!
        chapters = chapters.sorted { $0.chapterName.compare($1.chapterName , options: .numeric) == .orderedAscending }
        super.init(nibName: nil, bundle: nil)
        

    }
    init(model : Manga) {
        self.cdmodel = model
        cdchapters = model.chapters?.array as! [ChapterCD]
        cdchapters = cdchapters.sorted { $0.chapterName?.compare($1.chapterName! , options: .numeric) == .orderedAscending }
//        cdchapters = cdchapters.sorted(by: { chapter1 , chapter2 in
//            return chapter1.chapterName! < chapter2.chapterName!
//        })
        super.init(nibName: nil, bundle: nil)
    }

    init(model : Manga, index: Int) {
        self.cdmodel = model
        cdchapters = model.chapters?.array as! [ChapterCD]
        cdchapters = cdchapters.sorted { $0.chapterName?.compare($1.chapterName! , options: .numeric) == .orderedAscending }
//        cdchapters = cdchapters.sorted(by: { chapter1 , chapter2 in
//            return chapter1.chapterName! < chapter2.chapterName!
//        })
        self.index = index
        print("index = \(index)")
        super.init(nibName: nil, bundle: nil)
    }

    init(chapters : [Chapter], title:String, index: Int? = nil) {

        self.chapters = chapters.sorted { $0.chapterName.compare($1.chapterName , options: .numeric) == .orderedAscending }

        self.index = index
//        print("index = \(index)")
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }




    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = ColorHex.hexStringToUIColor(hex: HexColor.customGray.rawValue)
        view.backgroundColor = .tertiarySystemBackground

        let layout = UICollectionViewFlowLayout()
         layout.scrollDirection = .vertical
         layout.minimumLineSpacing = 1
         layout.minimumInteritemSpacing = 1
         layout.itemSize = CGSize(width: view.width/3-2, height: view.width/3-2)
         layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        guard let collectionView = collectionView else { return }
        collectionView.dataSource = self
        collectionView.delegate = self
        //fixing scroll of gridcollection view
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.register(GridHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: GridHeaderCollectionReusableView.identifier)
        collectionView.register(GridCollectionViewCell.self, forCellWithReuseIdentifier: GridCollectionViewCell.identifier)



        view.addSubview(collectionView)
        navigationItem.backButtonTitle = ""


    }
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    public func openFirstPage() {
        //зробити перевірку тут
        print("opning fisrt page")
        guard let collectionView = collectionView else { return }
        self.collectionView(collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
    }

    deinit {
        print("GridViewController deinit!")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.setNeedsLayout()
        setNeedsStatusBarAppearanceUpdate()

        guard let index = index else {
            print("index is nil")
            openFirstPage()
            index = 0
            return
        }
        print("index is not nil")
        
        let indexPath = IndexPath(item: 0, section: index)
        DispatchQueue.main.async {
            if let attributes = self.collectionView?.collectionViewLayout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath) {
                UIView.animate(withDuration: 0.5) {
                    self.collectionView?.setContentOffset(CGPoint(x: 0, y: attributes.frame.origin.y - (self.collectionView?.contentInset.top ?? 0)), animated: false)
                }
            }
//            self.collectionView?.scrollToItem(at: indexPath, at: .top, animated: false)
        }
        /*
        guard let cdmodel = cdmodel else {
            return
        }

        DatabaseCaller.shared.getChaptersWithLocalModel(for: cdmodel) { mangaDetail in
            print("fetched model!")
            self.model = mangaDetail
            self.collectionView?.reloadData()
        }
         */
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.bounds.width, height: view.bounds.height-view.safeAreaInsets.top)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension GridViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,UICollectionViewDelegate {



    func collectionView(_ collectionView: UICollectionView,didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        
//        if cdmodel == nil, let model = model {
            
//            guard let model = model else  { return }
//        let vc = SwipingController(model: model, indexPath: indexPath)
        let vc = SwipingController(chapters: chapters, indexPath: indexPath)
            vc.callback = { section in
                self.index = section
            }
        self.navigationController?.pushViewController(vc, animated: true)
//        print(indexPath.item)
//        } else if let model = cdmodel {
////            guard let model = cdmodel else { return }
//            let vc = SwipingController(model: model, indexPath: indexPath)
//            vc.callback = { section in
//                self.index = section
//            }
//            self.navigationController?.pushViewController(vc, animated: true)
////            print(indexPath.item)
//        }

    }

//MARK: - Collection View Header Stuff
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if cdmodel == nil {
        let section = chapters[indexPath.section]
        guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: GridHeaderCollectionReusableView.identifier, for: indexPath) as? GridHeaderCollectionReusableView  else { return UICollectionReusableView() }
        sectionHeader.configure(chapterName: section.chapterName)
        return sectionHeader
//        } else {
//            let section = cdchapters[indexPath.section]
//            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: GridHeaderCollectionReusableView.identifier, for: indexPath) as? GridHeaderCollectionReusableView  else { return UICollectionReusableView() }
//            sectionHeader.configure(chapterName: section.chapterName ?? "WHOOPs error")
//
//            return sectionHeader
//        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.width, height: 40)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        let number = cdmodel != nil ? cdchapters.count : chapters.count
//        return number
        return chapters.count
    }

//MARK: - Collection View CELL stuff
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if cdmodel == nil {
//            print("is this works?")
//        guard let item = model?.chapters?[indexPath.section].pages[indexPath.item] else { return UICollectionViewCell() }

            let url = chapters[indexPath.section].pages[indexPath.item].url
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCollectionViewCell.identifier, for: indexPath) as? GridCollectionViewCell else { return UICollectionViewCell() }

        cell.configure(url: url, pos: indexPath.item+1, max: chapters[indexPath.section].pages.count)
            return cell
//        } else {
//
//            let chapter = cdchapters[indexPath.section]
//            let pages = DataManager.shared.getSortedPages(for: chapter)
//            let item = pages[indexPath.item]
//
//
//            guard let url = item.url else { return UICollectionViewCell() }
//                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCollectionViewCell.identifier, for: indexPath) as? GridCollectionViewCell else { return UICollectionViewCell() }
//            cell.configure(key: url, pos: indexPath.item+1, max: chapter.pages?.count ?? 0)
//                return cell
//        }

    }



    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if cdmodel == nil {
//        guard let section = (model?.chapters?[section]) else { return 0 }
////        print("return section.pages.count: \(section.pages.count)")
//        return section.pages.count
//        } else {
////            print("chapters.count",cdchapters.count)
//            let sectionCd = cdchapters[section]
////            print(sectionCd)
//
//            let count = sectionCd.pages?.count
////            guard let count = section.pages?.count else { return 0}
////            print("return section.pages.count: \(sectionCd.pages?.count)")
//            return count!
//        }
        return chapters[section].pages.count
    }
}
