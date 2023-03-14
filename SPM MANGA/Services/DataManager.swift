//
//  DataManager.swift
//  SPM MANGA
//
//  Created by Nephilim  on 1/22/23.
//

import Foundation
import CoreData
import SDWebImage
import FirebaseStorage
import FirebaseStorageUI
import UIKit

class DataManager {
    static let shared = DataManager()
    private init() {}

    let notificationCenter = NotificationCenter.default
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Mangas")
        container.loadPersistentStores { storeDescription , error in
            if let error = error {
                fatalError("Unresolved error \(error), \(error.localizedDescription)")
            }
            print(storeDescription)
        }
        return container
    }()
    //MARK: - CoreData Saving Support
    func save() {
        let contex = persistentContainer.viewContext
        contex.performAndWait {
            if contex.hasChanges {
                do {
                    try contex.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.localizedDescription)")
                }
            }
        }
    }



    //    public func saveManga(model: MangaDetailModel, compliton: @escaping (Bool)->Void) {
    public func saveManga(model: MangaDetailModel) {
        //TODO: check if manga already exists
        //it checks if manga already exists and if not, so creates a new one
        saveMangaToCD(model: model) { manga in
            print("got the manga!")
            self.saveChapter(for: manga ,with:model.chapters!)

        }

    }



    public func favoriteManga(with title:String) {
        guard isFavorite(with: title) == false else { return }

        let newFav = Favorite(context: persistentContainer.viewContext)
        newFav.title = title
        save()
    }

    public func unfavoriteManga(with title: String) {
        let request = Favorite.fetchRequest()
        let predicate = NSPredicate(format: "title = %@", title)
        request.predicate = predicate
        do {
            let favorite = try persistentContainer.viewContext.fetch(request).first!
            persistentContainer.viewContext.delete(favorite)
            save()
        } catch {
            print("Error deleting from favorite \(error)")
        }

    }

    public func isFavorite(with title:String) -> Bool {

        let request = Favorite.fetchRequest()

        let predicate = NSPredicate(format: "title = %@" , title)

        request.predicate = predicate
        var isFavorite = false
        do {

            if (try persistentContainer.viewContext.fetch(request).first) != nil {
//                let fetchedFav = try persistentContainer.viewContext.fetch(request).first!
                isFavorite = true
            } else {
                //                return nil
                isFavorite = false
            }
        } catch {
            print("Error fetching favorite \(error)")
        }
        return isFavorite

    }

    public func getFavoriteMangas() -> [String] {
        let request = Favorite.fetchRequest()
        var array : [String] = []
        do {
            let result = try persistentContainer.viewContext.fetch(request)
            result.forEach { favorite in
                let title = favorite.title!
                print(title)
                array.append(title)
            }

        } catch let error {
            print("Error fetching singers \(error)")
        }
        print("array of titles = \(array)")
        return array
    }

    

    private func saveMangaToCD(model: MangaDetailModel, complition: @escaping (Manga) -> Void ) -> Void {
        //MARK: - check here if manga already exists

        let result = createOrUpdateManga(title: model.title)
        if let manga = result.1 {
            complition(manga)
            return
        }
        
        let manga = Manga(context: persistentContainer.viewContext)
        let reference = Storage.storage().reference(forURL: model.coverURL)
        manga.title = model.title
        manga.directory = model.directory

        manga.author = model.author
        manga.genras = model.genras
        manga.isFinished = model.isFinished
        manga.isTranslated = model.isTranslated
        manga.releaseYear = Int16(model.release)
        manga.status = model.status
        manga.translation = model.translation
        manga.volumesCount = Int16(model.volumesCount)


        reference.downloadURL { url, error in
            SDWebImageDownloader.shared.downloadImage(with: url) { image, data, error, isFinished in
                if isFinished {
//                    print(model.coverURL)
//                    print(url?.absoluteString)
                    SDImageCache.shared.store(image, forKey: model.coverURL, toDisk: true) {
                        //                        print("saved image to disk")
                        manga.cover = model.coverURL
                        manga.descript = model.description
                        manga.chaptersCount = Int16(model.chaptersCount)
                        self.save()
                        complition(manga)

                        //                        self.saveChapter(for: manga ,with:model.chapters!)
                    }
                }
            }
        }

    }

    private func saveChapter(for manga:Manga, with chapters: [Chapter]) {

        let group = DispatchGroup()

        if manga.chapters?.count == chapters.count {
            print("all chapters already has been saved!")
            //MARK: - Calling notification center
            self.notificationCenter.post(name: .downloadedAlready, object: nil)
        }
//        var chaptersToDownlaod = chapters.count
        chapters.forEach { chapter in
            group.enter()
            if !existsChapter(with: chapter.chapterID){
                let newChapter = ChapterCD(context: persistentContainer.viewContext)
                newChapter.manga = manga
                newChapter.chapterID = chapter.chapterID
                newChapter.chapterName = chapter.chapterName
                savePages(for: newChapter, pages: chapter.pages) { finished in
                    if finished {
                        group.leave()
//                        if chapters.count > 1 {
//                            chaptersToDownlaod -= 1
//                            print("chaptersToDownlaod = \(chaptersToDownlaod)")
//                            guard chaptersToDownlaod == 0 else { return }
//                            self.showAlert(mangaTitle: manga.title!)
//                            self.notificationCenter.post(name: .downloadSuccess, object: nil)
//                        } else {
//                            self.notificationCenter.post(name: .downloadSuccess, object: nil)
//                        }

                    }
                }
            } else {
                print("chapter already exists")
                group.leave()
            }

        }
        group.notify(queue: .main) {
            print("we re all done!")
            self.showAlert(mangaTitle: manga.title!)
            self.notificationCenter.post(name: .downloadSuccess, object: nil)
        }
    }

    public func saveChapter(for model: MangaDetailModel, with chapters: [Chapter]) {
        var chaptersToDownlaod = chapters.count
        saveMangaToCD(model: model, complition: { manga in
            chapters.forEach { chapter in
                let newChapter = ChapterCD(context: self.persistentContainer.viewContext)
                newChapter.manga = manga
                newChapter.chapterID = chapter.chapterID
                newChapter.chapterName = chapter.chapterName
                self.savePages(for: newChapter, pages: chapter.pages) { finished in
                    if finished {
                        if chaptersToDownlaod > 1 {
                            chaptersToDownlaod -= 1
                            print("chaptersToDownlaod = \(chaptersToDownlaod)")
                            guard chaptersToDownlaod == 0 else { return }
                            self.showAlert(mangaTitle: manga.title!)
                            self.notificationCenter.post(name: .downloadSuccess, object: nil)
                        } else {
                            self.notificationCenter.post(name: .downloadSuccess, object: nil)
                        }

                    }
                }
            }
        })

    }
    //this method we call from swipe gesture
    public func saveChapterWithCompilation(for model: MangaDetailModel, with chapters: [Chapter], complitation: @escaping (Bool)->Void) {
        saveMangaToCD(model: model, complition: { manga in
            chapters.forEach { chapter in
                let newChapter = ChapterCD(context: self.persistentContainer.viewContext)
                newChapter.manga = manga
                newChapter.chapterID = chapter.chapterID
                newChapter.chapterName = chapter.chapterName
                //            save()
                self.savePages(for: newChapter, pages: chapter.pages) { finished in
                    if finished  {
                        self.notificationCenter.post(name: .downloadSuccess, object: nil)
                        complitation(true)
                    }
                }
//                complitation(true)
            }
        })


    }
    //    //MARK: - todo later
    //    public func saveManga(manga model:MangaDetailModel, with chapters: [Chapter], chaptersToSave: [Chapter]) {
    //        saveMangaToCD(model: model, complition: { manga in
    //            chaptersToSave.forEach { chapter in
    //                let newChapter = ChapterCD(context: self.persistentContainer.viewContext)
    //                newChapter.manga = manga
    //                newChapter.chapterName = chapter.chapterName
    //    //            save()
    //                self.savePages(for: newChapter, pages: chapter.pages)
    //            }
    //            chapters.forEach { chapter in
    //                if !DataManager.shared.existsChapter(with: chapter.chapterName) {
    //                    let newChapter = ChapterCD(context: self.persistentContainer.viewContext)
    //                    newChapter.manga = manga
    //                    newChapter.chapterName = chapter.chapterName
    //                    self.save()
    //                }
    //            }
    //
    //        })
    //
    //    }

    
    func savePages(for chapter: ChapterCD, pages: [MangaPage], complition: @escaping ((Bool) -> Void)) {
        var pageCount = 0
//        var totalPercetage: Double = 0
//        let onePeace = 1.0 / Double(pages.count)

        for mangaPage in pages {
//            var chaptersDownloaded = 0
            SDImageCache.shared.diskImageExists(withKey: mangaPage.url, completion: { exist in
                if exist {
                    pageCount += 1
//                    print("this image already exists lol ")
                    let newPage = PageCD(context: self.persistentContainer.viewContext)
                    newPage.orderIndex = String(mangaPage.orderIndex)
                    newPage.url = mangaPage.url
                    chapter.addToPages(newPage)
                    self.save()
//                    totalPercetage += onePeace
//                    print("total percetage = \(totalPercetage)")
                    if chapter.pages?.array.count == pages.count {
                        self.notificationCenter.post(name: .downloadSuccess, object: nil)
                    }
                } else {
//                    var chaptersDownloaded = 0
                    let reference = Storage.storage().reference(forURL: mangaPage.url)

                    reference.downloadURL { url, error in
                        SDWebImageDownloader.shared.downloadImage(with: url) { image, data, error, isFinished in
                            if isFinished {
//                                totalPercetage += onePeace
//                                print("total percetage = \(totalPercetage)")

                                pageCount += 1
//                                print(pageCount)
                                SDImageCache.shared.store(image, forKey: mangaPage.url, toDisk: true) {
                                    let newPage = PageCD(context: self.persistentContainer.viewContext)
                                    newPage.orderIndex = String(mangaPage.orderIndex)
                                    newPage.url = mangaPage.url
                                    chapter.addToPages(newPage)
                                    self.save()
//                                    totalPercetage += onePeace
//                                    print("total percetage = \(totalPercetage)")
//                                    chaptersDownloaded == chapter.manga?.chapters?.array.count

                                    if chapter.pages?.array.count == pages.count {

                                        complition(true)


                                    }
//                                    if chapter.manga?.chapters?.array.count == chaptersDownloaded {
//                                        print("chapters are downloaded")
//                                    }
                                }

                            }
                        }
                    }
//                    print("done!")
                }
//                print("done!!")
            })



        }
//        print("done!!!")
        //        pages.forEach { mangaPage in
        //            SDImageCache.shared.diskImageExists(withKey: mangaPage.url, completion: { exist in
        //                if exist {
        //                    pageCount += 1
        //                    print("this image already exists lol ")
        //                    let newPage = PageCD(context: self.persistentContainer.viewContext)
        //                    newPage.orderIndex = String(mangaPage.orderIndex)
        //                    newPage.url = mangaPage.url
        //                    chapter.addToPages(newPage)
        //                    self.save()
        //                    if chapter.pages?.array.count == pages.count {
        //                        self.notificationCenter.post(name: .downloadSuccess, object: nil)
        //                    }
        //                } else {
        //                    let reference = Storage.storage().reference(forURL: mangaPage.url)
        //                    reference.downloadURL { url, error in
        //                        SDWebImageDownloader.shared.downloadImage(with: url) { image, data, error, isFinished in
        //                            if isFinished {
        //                                //                        totalPercetage += onePeace
        //                                //                        print("total percetage = \(totalPercetage)")
        //                                pageCount += 1
        //                                print(pageCount)
        //                                SDImageCache.shared.store(image, forKey: mangaPage.url, toDisk: true) {
        //                                    let newPage = PageCD(context: self.persistentContainer.viewContext)
        //                                    newPage.orderIndex = String(mangaPage.orderIndex)
        //                                    newPage.url = mangaPage.url
        //                                    chapter.addToPages(newPage)
        //                                    self.save()
        //                                    if chapter.pages?.array.count == pages.count {
        //                                        self.notificationCenter.post(name: .downloadSuccess, object: nil)
        //
        //                                    }
        //                                }
        //                            }
        //                        }
        //                    }
        //                }
        //            })
        //        }

        //        print("Done!!!")
    }

    //delete this if youare not using it anymore, this is function without complition
    func savePagesOld(for chapter: ChapterCD, pages: [MangaPage]) {
        var pageCount = 0
//        var totalPercetage: Double = 0
//        let onePeace = 1.0 / Double(pages.count)

        SDWebImageDownloader.shared.config.maxConcurrentDownloads = 1





                pages.forEach { mangaPage in
                    SDImageCache.shared.diskImageExists(withKey: mangaPage.url, completion: { exist in
                        if exist {
                            pageCount += 1
                            print("this image already exists lol ")
                            let newPage = PageCD(context: self.persistentContainer.viewContext)
                            newPage.orderIndex = String(mangaPage.orderIndex)
                            newPage.url = mangaPage.url
                            chapter.addToPages(newPage)
                            self.save()
                            if chapter.pages?.array.count == pages.count {
                                self.notificationCenter.post(name: .downloadSuccess, object: nil)
                            }
                        } else {
                            let reference = Storage.storage().reference(forURL: mangaPage.url)
                            reference.downloadURL { url, error in
                                SDWebImageDownloader.shared.downloadImage(with: url) { image, data, error, isFinished in
                                    if isFinished {
                                        //                        totalPercetage += onePeace
                                        //                        print("total percetage = \(totalPercetage)")
                                        pageCount += 1
                                        print(pageCount)
                                        SDImageCache.shared.store(image, forKey: mangaPage.url, toDisk: true) {
                                            let newPage = PageCD(context: self.persistentContainer.viewContext)
                                            newPage.orderIndex = String(mangaPage.orderIndex)
                                            newPage.url = mangaPage.url
                                            chapter.addToPages(newPage)
                                            self.save()
//                                            if chapter.pages?.array.count == pages.count {
//                                                self.notificationCenter.post(name: .downloadSuccess, object: nil)
//
//                                            }
                                        }
                                    }
                                }
                            }
                        }
                    })
                }
    }

    //MARK: - TODO make it to fetch not MANGA objects but MangaDeteilModels
    func fetchMangas() -> [Manga] {
        let request: NSFetchRequest<Manga> = Manga.fetchRequest()
        var fetchedMangas: [Manga] = []
        do {
            let sort = NSSortDescriptor(key: #keyPath(Manga.title), ascending: false)
            request.sortDescriptors = [sort]
            fetchedMangas = try persistentContainer.viewContext.fetch(request)

        } catch let error {
            print("Error fetching singers \(error)")
        }
        return fetchedMangas
    }



    //MARK: - TODO
    //MARK: - CHANGE IT TO CHECK WITH UUID
    public func fetchManga(with title: String) -> Manga? {
        //        var fetchedManga: Manga
        let request: NSFetchRequest<Manga> = Manga.fetchRequest()
        request.fetchLimit = 1
        do {
            let predicate = NSPredicate(format: "title = %@" , title)

            request.predicate = predicate
            if let fetchedManga = try persistentContainer.viewContext.fetch(request).first {
                //                print(fetchedManga)
                return fetchedManga
            } else {
                return nil
            }
        } catch let error {
            print("Error fetching singers \(error)")
        }
        return nil
        //        return fetchedMangas
    }

    public func existsChapter(with id: String) -> Bool {

        let request: NSFetchRequest<ChapterCD> = ChapterCD.fetchRequest()
        request.fetchLimit = 1
        do {
            let predicate = NSPredicate(format: "chapterID = %@" , id)

            request.predicate = predicate
            if (try persistentContainer.viewContext.fetch(request).first) != nil {
                //                print(fetchedChapter)
                return true
            } else {
                return false
            }
        } catch let error {
            print("Error fetching singers \(error)")
        }
        return false

    }


    public func getSortedChapters(for manga: Manga) -> [ChapterCD] {
        let chapters = manga.chapters?.array as! [ChapterCD]

        //        let sorted:[ChapterCD] = chapters.sorted{$0.chapterName! > $1.chapterName!}
        let sorted:[ChapterCD] = chapters.sorted { $0.chapterName?.compare($1.chapterName! , options: .numeric) == .orderedDescending }

        //        chapters = chapters?.sorted { $0.chapterName.compare($1.chapterName , options: .numeric) == .orderedDescending }
        return sorted
    }
    public func getSortedPages(for chapter: ChapterCD) -> [PageCD] {
        let pages = chapter.pages?.array as! [PageCD]
        let sorted:[PageCD] = pages.sorted{$0.orderIndex! < $1.orderIndex!}
        return sorted

    }

    public func createOrUpdateManga(title:String) -> (Bool,Manga?) {
        //        var manga: Manga
        let managedContex = persistentContainer.viewContext
        let fetchedRequest = NSFetchRequest<NSManagedObject>(entityName: "Manga")
        fetchedRequest.fetchLimit = 1
        fetchedRequest.predicate = NSPredicate(format: "title == %@", title)
        do {
            let count = try managedContex.count(for: fetchedRequest)
            var result = [NSManagedObject]()
            result = try managedContex.fetch(fetchedRequest)
            if result.count > 0 {
                var manga: Manga
                manga = result.first as! Manga
                return (true, manga)
            } else {
                return (false, nil)
            }
        } catch let error as NSError {
            print("could not fetch, \(error) , \(error.localizedDescription)")
            return (false,nil)
        }
    }

    func delete(manga: Manga) {

        let chapters = manga.chapters?.array as! [ChapterCD]
        chapters.forEach({ chapter in
            let pages = chapter.pages?.array as! [PageCD]
            pages.forEach({ page in
                SDImageCache.shared.removeImageFromDisk(forKey: page.url)
            })
        })
        let contex = persistentContainer.viewContext
        contex.delete(manga)
        save()

    }

    public func howMuchCache() -> String {
        let bytes = SDImageCache.shared.totalDiskSize()
        let mbs = bytes/1024/1024
        print("total cache size is \(mbs) mb")
        return String(mbs)
    }

    public func clearCache() {
        SDImageCache.shared.diskCache.removeAllData()
        print("disk is cleared")
    }


    public func deleteAllMangas() {
        let mangas = fetchMangas()
        let contex = persistentContainer.viewContext
        mangas.forEach { manga in
            contex.delete(manga)
            save()
        }
    }

    public func downloadImage(_ url:String, imagee: @escaping (UIImage)-> Void) {
        let reference = Storage.storage().reference(forURL: url)
        reference.downloadURL { donwloadUrl, error in
            SDWebImageDownloader.shared.downloadImage(with: donwloadUrl, options: .highPriority, progress: nil) {
                image, data, error, isFinished in
                if isFinished, let image = image {
                    SDImageCache.shared.store(image, forKey: url, toDisk: true, completion: nil)
                    imagee(image)
                }
            }
//            SDWebImageDownloader.shared.downloadImage(with: donwloadUrl) {
//                image, data, error, isFinished in
//                if isFinished, let image = image {
//                    SDImageCache.shared.store(image, forKey: url, toDisk: true, completion: nil)
//                    imagee(image)
//                }
//            }
        }
    }


    public func clearDatabase() {
        guard let url = persistentContainer.persistentStoreDescriptions.first?.url else { return }
        print("URL = \(url)")
        let persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator

        do {
            try persistentStoreCoordinator.destroyPersistentStore(at:url, ofType: NSSQLiteStoreType, options: nil)
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            print("Attempted to clear persistent store: " + error.localizedDescription)
        }
    }

    private func showAlert(mangaTitle: String) {
        let alert = UIAlertController(title: "Всі розділи \n\(mangaTitle) \nзавантажені", message: "", preferredStyle: .alert)
//        alert.view.backgroundColor = ColorHex.hexStringToUIColor(hex: HexColor.pinkishColor.rawValue)

        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}

