//
//  Favorite+CoreDataProperties.swift
//  SPM MANGA
//
//  Created by Nephilim  on 2/15/23.
//
//

import Foundation
import CoreData

extension Favorite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite> {
        return NSFetchRequest<Favorite>(entityName: "Favorite")
    }

    @NSManaged public var title: String?

}

extension Favorite: Identifiable {

}
