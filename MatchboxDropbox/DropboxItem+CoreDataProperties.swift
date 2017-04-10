//
//  DropboxItem+CoreDataProperties.swift
//  MatchboxDropbox
//
//  Created by Neil Skinner on 09/04/2017.
//  Copyright © 2017 Neil Skinner. All rights reserved.
//

import Foundation
import CoreData


extension DropboxItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DropboxItem> {
        return NSFetchRequest<DropboxItem>(entityName: "DropboxItem")
    }

    @NSManaged public var name: String?
    @NSManaged public var path_display: String?
    @NSManaged public var size: Int32
    @NSManaged public var tag: String?
    @NSManaged public var itemId: String?
    @NSManaged public var path_root: String?

}
