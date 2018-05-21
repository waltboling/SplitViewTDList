//
//  DetailList+CoreDataProperties.swift
//  SplitViewTDList
//
//  Created by Jon Boling on 5/21/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//
//

import Foundation
import CoreData


extension DetailList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DetailList> {
        return NSFetchRequest<DetailList>(entityName: "DetailList")
    }

    @NSManaged public var detailTitle: String
    @NSManaged public var withMaster: MasterList

}
