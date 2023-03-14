//
//  ChapterCD+CoreDataProperties.swift
//  SPM MANGA
//
//  Created by Nephilim  on 2/18/23.
//
//

import Foundation
import CoreData


extension ChapterCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChapterCD> {
        return NSFetchRequest<ChapterCD>(entityName: "ChapterCD")
    }

    @NSManaged public var chapterName: String?
    @NSManaged public var chapterID: String?
    @NSManaged public var manga: Manga?
    @NSManaged public var pages: NSOrderedSet?

}

// MARK: Generated accessors for pages
extension ChapterCD {

    @objc(insertObject:inPagesAtIndex:)
    @NSManaged public func insertIntoPages(_ value: PageCD, at idx: Int)

    @objc(removeObjectFromPagesAtIndex:)
    @NSManaged public func removeFromPages(at idx: Int)

    @objc(insertPages:atIndexes:)
    @NSManaged public func insertIntoPages(_ values: [PageCD], at indexes: NSIndexSet)

    @objc(removePagesAtIndexes:)
    @NSManaged public func removeFromPages(at indexes: NSIndexSet)

    @objc(replaceObjectInPagesAtIndex:withObject:)
    @NSManaged public func replacePages(at idx: Int, with value: PageCD)

    @objc(replacePagesAtIndexes:withPages:)
    @NSManaged public func replacePages(at indexes: NSIndexSet, with values: [PageCD])

    @objc(addPagesObject:)
    @NSManaged public func addToPages(_ value: PageCD)

    @objc(removePagesObject:)
    @NSManaged public func removeFromPages(_ value: PageCD)

    @objc(addPages:)
    @NSManaged public func addToPages(_ values: NSOrderedSet)

    @objc(removePages:)
    @NSManaged public func removeFromPages(_ values: NSOrderedSet)

}

extension ChapterCD : Identifiable {

}
