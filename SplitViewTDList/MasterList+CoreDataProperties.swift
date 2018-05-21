//
//  MasterList+CoreDataProperties.swift
//  SplitViewTDList
//
//  Created by Jon Boling on 5/21/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//
//

import Foundation
import CoreData


extension MasterList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MasterList> {
        return NSFetchRequest<MasterList>(entityName: "MasterList")
    }

    @NSManaged public var masterTitle: String?
    @NSManaged public var withDetail: NSSet?

}

// MARK: Generated accessors for withDetail
extension MasterList {

    @objc(addWithDetailObject:)
    @NSManaged public func addToWithDetail(_ value: DetailList)

    @objc(removeWithDetailObject:)
    @NSManaged public func removeFromWithDetail(_ value: DetailList)

    @objc(addWithDetail:)
    @NSManaged public func addToWithDetail(_ values: NSSet)

    @objc(removeWithDetail:)
    @NSManaged public func removeFromWithDetail(_ values: NSSet)

}
