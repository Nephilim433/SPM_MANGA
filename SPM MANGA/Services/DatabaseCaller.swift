import FirebaseStorage
import Firebase
import FirebaseDatabase
import FirebaseStorageUI
import CoreData
import SDWebImage

class DatabaseCaller {
    let storage = Storage.storage()
    var ref = Database.database().reference()

    static var persistentContainer = NSPersistentContainer(name:"Mangas") 
    private var managedObjectContext : NSManagedObjectContext?

    static let shared = DatabaseCaller()
    private init() {}

    //MARK: - FireBaseCalls
    public func getRootDirectories(complition: @escaping ([String])-> Void) {
        self.ref.observeSingleEvent(of: .value) { snapshot in
            let enumerator = snapshot.children
            var folders = [String]()
        //MARK: TODO: - Change it to groupdispatch?
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let mangaFolder = rest.key
                folders.append(mangaFolder)
                if folders.count == snapshot.childrenCount {
                    complition(folders)
                }
            }
        }
        getMangaNamesByRelease { _ in
            print("hao")

        }
    }
    public func getMangaNamesByRelease(complition: @escaping ([String])-> Void) {

        ref.queryOrdered(byChild: "lastUpdated").queryLimited(toLast: 5).observe(DataEventType.value) { snapshot in
            let enumerator = snapshot.children
//            var folders = [String]()
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let mangaFolder = rest.key
                print("mangaFolder = \(mangaFolder)")
            }
        }
    }

    public func getFavorites(for mangas: [String], complition: @escaping ([MangaDetailModel]) -> Void) {

        var models = [MangaDetailModel]()
        for manga in mangas {
            self.ref.child(manga).child("chapters").observeSingleEvent(of: .value) { snapshot in
                let chaptersCount = snapshot.childrenCount

            self.ref.child(manga).observeSingleEvent(of: .value) { snapshot in

                let value = snapshot.value as? Dictionary<String, Any>
                guard let title = value?["title"] as? String,
                      let cover = value?["cover"] as? String,
                      let description = value?["description"] as? String,
                      let genras = value?["genras"] as? String,
                      let author = value?["author"] as? String,
                      let release = value?["release"] as? Int,
                      let status = value?["status"] as? String,
                      let translation = value?["translation"] as? String,
                      let volumes = value?["volumes"] as? Int,
                      let isFinished = value?["isFinished"] as? Bool,
                      let isTranslated = value?["isTranslated"] as? Bool
                else { return }

                models.append(MangaDetailModel(title: title, coverURL: cover, chaptersCount: Int(chaptersCount), volumesCount: volumes, genras: genras, description: description, directory: manga, chapters: nil, author: author, status: status, translation: translation, release: release,isTranslated: isTranslated, isFinished:isFinished))

                if models.count == mangas.count {

                    complition(models)
                    }
                }
            }
        }
    }


    public func getMangaDetails(complition: @escaping ([MangaDetailModel]) -> Void) {
        var models = [MangaDetailModel]()
        getRootDirectories { directories in
            for directory in directories {
//                print("root directory = \(directory)")
                self.ref.child(directory).child("chapters").observeSingleEvent(of: .value) { snapshot in
                    let chaptersCount = snapshot.childrenCount

                self.ref.child(directory).observeSingleEvent(of: .value) { snapshot in

                    let value = snapshot.value as? Dictionary<String, Any>

                    guard let title = value?["title"] as? String,
                          let cover = value?["cover"] as? String,
                          let description = value?["description"] as? String,
                          let genras = value?["genras"] as? String,
                          let author = value?["author"] as? String,
                          let release = value?["release"] as? Int,
                          let status = value?["status"] as? String,
                          let translation = value?["translation"] as? String,
                          let volumes = value?["volumes"] as? Int,
                          let isFinished = value?["isFinished"] as? Bool,
                          let isTranslated = value?["isTranslated"] as? Bool
                    else { return }

//                    print("genras = \(genras)")

                    models.append(MangaDetailModel(title: title, coverURL: cover, chaptersCount: Int(chaptersCount), volumesCount: volumes, genras: genras, description: description, directory: directory, chapters: nil, author: author, status: status, translation: translation, release: release,isTranslated: isTranslated, isFinished:isFinished))

                    if models.count == directories.count {

                        complition(models)
                        }
                    }
                }
            }
        }
    }

    public func queryMangas(with text: String, complition: @escaping ([MangaDetailModel]) -> Void) {
        var models = [MangaDetailModel]()
        getRootDirectories { directories in
            var filteredDirs: [String] = []
            directories.forEach { directory in
                let lowerCased = directory.lowercased()
                print("lowerCased = \(lowerCased)")
                if lowerCased.contains(text.lowercased()) {
                    filteredDirs.append(directory)
                    print("this = \(lowerCased) contains this = \(text)")
                }
            }
            print("lowerCasedDirs.count = \(filteredDirs.count)")
            filteredDirs.forEach {  dir in

                    self.ref.child(dir).child("chapters").observeSingleEvent(of: .value) { snapshot in
                        let chaptersCount = snapshot.childrenCount

                        self.ref.child(dir).observeSingleEvent(of: .value) { snapshot in

                            let value = snapshot.value as? Dictionary<String, Any>
                            guard let title = value?["title"] as? String,
                                  let cover = value?["cover"] as? String,
                                  let description = value?["description"] as? String,
                                  let genras = value?["genras"] as? String,
                                  let author = value?["author"] as? String,
                                  let release = value?["release"] as? Int,
                                  let status = value?["status"] as? String,
                                  let translation = value?["translation"] as? String,
                                  let volumes = value?["volumes"] as? Int,
                                  let isFinished = value?["isFinished"] as? Bool,
                                  let isTranslated = value?["isTranslated"] as? Bool
                            else { return }

                            print("genras = \(genras)")

                            models.append(MangaDetailModel(title: title, coverURL: cover, chaptersCount: Int(chaptersCount), volumesCount: volumes, genras: genras, description: description, directory: dir, chapters: nil, author: author, status: status, translation: translation, release: release,isTranslated: isTranslated, isFinished:isFinished))


                            if models.count == filteredDirs.count {
                                complition(models)
                            }
                    }
                }
            }
        }
    }

    public func getChapters(for mangaModel: MangaDetailModel, complition: @escaping (MangaDetailModel) -> Void) {
        var chapters = [Chapter]()
        self.ref.child(mangaModel.directory).child("chapters").observeSingleEvent(of: .value) { snapshot in
            for chapter in snapshot.children {
                guard let chapterChild = chapter as? DataSnapshot else { return }
                let value = chapterChild.value as? [String:Any]
                print(chapterChild.key)
                let id = value?["uuid"] as? String ?? "none"
                print("id = \(id)")
                var pages = [MangaPage]()
                print("<><><><><><><><><><><><><><><")
                for child2 in chapterChild.children {
                    guard let child = child2 as? DataSnapshot else { return }

                    let value = child.value as? [String:Any]
                    //temporaly
                    guard let url = value?["url"] as? String,let childKey = Int(child.key) else { continue }

                        let page = MangaPage(orderIndex: childKey, url: url)
                        pages.append(page)
                }
                print("just got UUID = \(id)")
                let chapterModel = Chapter(chapterName: chapterChild.key, chapterID: id, pages: pages)
                chapters.append(chapterModel)

            }
            let model = MangaDetailModel(title: mangaModel.title, coverURL: mangaModel.coverURL, chaptersCount: mangaModel.chaptersCount, volumesCount: mangaModel.volumesCount, genras: mangaModel.genras, description: mangaModel.description, directory: mangaModel.directory, chapters: chapters, author: mangaModel.author,status: mangaModel.status,translation: mangaModel.translation ,release:mangaModel.release, isTranslated: mangaModel.isTranslated, isFinished: mangaModel.isFinished)

            complition(model)

        }
    }

    //MARK: - trying to change for fetching with Core Data Model
    public func getChaptersWithLocalModel(for mangaModel: Manga, complition: @escaping (MangaDetailModel) -> Void) {
        var chapters = [Chapter]()
        guard let name = mangaModel.title, let cover = mangaModel.cover, let author = mangaModel.author,let genras = mangaModel.genras,let status = mangaModel.status, let translation = mangaModel.translation,let description = mangaModel.descript else { return }
        let isFinished = mangaModel.isFinished
        let isTranslated = mangaModel.isTranslated
        let volumesCount = Int(mangaModel.volumesCount)
        let chaptersCount = Int(mangaModel.chaptersCount)
        let release = Int(mangaModel.releaseYear)
        self.ref.child(name).child("chapters").observeSingleEvent(of: .value) { snapshot in
            for chapter in snapshot.children {
                guard let chapterChild = chapter as? DataSnapshot else { return }
                let value = chapterChild.value as? [String:Any]
                print(chapterChild.key)
                let id = value?["uuid"] as? String ?? "none"
                print("id = \(id)")

                var pages = [MangaPage]()
                print("<><><><><><><><><><><><><><><")
                for child2 in chapterChild.children {
                    guard let child = child2 as? DataSnapshot else { return }

                    let value = child.value as? [String:Any]

                    //temporaly
                    let childKey = Int(child.key) ?? 0
                    let url = value?["url"] as? String ?? "none"
                    let page = MangaPage(orderIndex: childKey, url: url)
                    pages.append(page)
                }
                print("just got UUID = \(id)")
                let chapterModel = Chapter(chapterName: chapterChild.key, chapterID: id, pages: pages)
                chapters.append(chapterModel)

            }
            let model = MangaDetailModel(title: name, coverURL: cover, chaptersCount: chaptersCount, volumesCount: volumesCount, genras: genras, description: description, directory: name, chapters: chapters, author: author, status: status, translation: translation, release: release, isTranslated: isTranslated, isFinished: isFinished)

            complition(model)

        }
    }

    //MARK: - Saving locally / CoreData / SDWebImage
    private func saveImgLocal(url : String, complition: @escaping (String)->Void) {
        SDWebImageDownloader.shared.downloadImage(with: URL(string: url)) { image, data, error, isFinished in
            if isFinished {
                print(url)
                SDImageCache.shared.store(image, forKey: url, toDisk: true) {
                    print("saved image to disk")
                    complition(url)
                }
            }
        }
    }
    public func saveToCoreData(with model: MangaDetailModel ,complition: @escaping (Bool) -> Void) {
        self.managedObjectContext = DatabaseCaller.persistentContainer.viewContext
        guard let context = managedObjectContext else {
            return
        }
        
        let manga = Manga(context: context)
        saveImgLocal(url: model.coverURL) { manga.cover = $0 }
        manga.descript = model.description
        manga.title = model.title
        manga.chaptersCount = Int16(model.chaptersCount)
        manga.volumesCount = Int16(model.volumesCount)


        var cdChapters = [ChapterCD]()
        model.chapters?.forEach({ chapter in
            let newChapter = ChapterCD(context: context)
            newChapter.chapterName = chapter.chapterName

            chapter.pages.forEach { mangaPage in
                let newPage = PageCD(context: context)
                saveImgLocal(url: mangaPage.url) { newPage.url = $0 }
                newPage.orderIndex = String(mangaPage.orderIndex)
                newChapter.addToPages(newPage)

            }
            cdChapters.append(newChapter)
            manga.addToChapters(newChapter)



        })
        do {
            try context.save()
            complition(true)
        } catch let error {
            print("error occures", error)
        }


    }

//    public func clearDatabase() {
//        guard let url = DatabaseCaller.persistentContainer.persistentStoreDescriptions.first?.url else { return }
//        print("URL = \(url)")
//        let persistentStoreCoordinator = DatabaseCaller.persistentContainer.persistentStoreCoordinator
//
//         do {
//             try persistentStoreCoordinator.destroyPersistentStore(at:url, ofType: NSSQLiteStoreType, options: nil)
//             try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
//         } catch {
//             print("Attempted to clear persistent store: " + error.localizedDescription)
//         }
//    }

}
