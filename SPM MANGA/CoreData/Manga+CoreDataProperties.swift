//
//  Manga+CoreDataProperties.swift
//  SPM MANGA
//
//  Created by Nephilim  on 2/18/23.
//
//

import Foundation
import CoreData

extension Manga {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Manga> {
        return NSFetchRequest<Manga>(entityName: "Manga")
    }

    @NSManaged public var author: String?
    @NSManaged public var chaptersCount: Int16
    @NSManaged public var cover: String?
    @NSManaged public var descript: String?
    @NSManaged public var directory: String?
    @NSManaged public var genras: String?
    @NSManaged public var status: String?
    @NSManaged public var title: String?
    @NSManaged public var translation: String?
    @NSManaged public var volumesCount: Int16
    @NSManaged public var releaseYear: Int16
    @NSManaged public var isTranslated: Bool
    @NSManaged public var isFinished: Bool
    @NSManaged public var chapters: NSOrderedSet?

}

// MARK: Generated accessors for chapters
extension Manga {

    @objc(insertObject:inChaptersAtIndex:)
    @NSManaged public func insertIntoChapters(_ value: ChapterCD, at idx: Int)

    @objc(removeObjectFromChaptersAtIndex:)
    @NSManaged public func removeFromChapters(at idx: Int)

    @objc(insertChapters:atIndexes:)
    @NSManaged public func insertIntoChapters(_ values: [ChapterCD], at indexes: NSIndexSet)

    @objc(removeChaptersAtIndexes:)
    @NSManaged public func removeFromChapters(at indexes: NSIndexSet)

    @objc(replaceObjectInChaptersAtIndex:withObject:)
    @NSManaged public func replaceChapters(at idx: Int, with value: ChapterCD)

    @objc(replaceChaptersAtIndexes:withChapters:)
    @NSManaged public func replaceChapters(at indexes: NSIndexSet, with values: [ChapterCD])

    @objc(addChaptersObject:)
    @NSManaged public func addToChapters(_ value: ChapterCD)

    @objc(removeChaptersObject:)
    @NSManaged public func removeFromChapters(_ value: ChapterCD)

    @objc(addChapters:)
    @NSManaged public func addToChapters(_ values: NSOrderedSet)

    @objc(removeChapters:)
    @NSManaged public func removeFromChapters(_ values: NSOrderedSet)

}

extension Manga: Identifiable {

}
