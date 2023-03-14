//
//  PageCD+CoreDataProperties.swift
//  SPM MANGA
//
//  Created by Nephilim  on 2/15/23.
//
//

import Foundation
import CoreData


extension PageCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PageCD> {
        return NSFetchRequest<PageCD>(entityName: "PageCD")
    }

    @NSManaged public var orderIndex: String?
    @NSManaged public var url: String?
    @NSManaged public var chapter: ChapterCD?

}

extension PageCD : Identifiable {

}
