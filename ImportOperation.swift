//
//  ImportOperation.swift
//  MatchboxDropbox
//
//  Created by Neil Skinner on 08/04/2017.
//  Copyright © 2017 Neil Skinner. All rights reserved.
//

import CoreData
import UIKit

/**
 Operation to allow async importing of file details
 */
class ImportOperation: Operation {
    
    let entries:[[String:Any]]
    let rootPath:String
    
    init(rootPath:String, entries: [[String:Any]]) {
        self.entries = entries
        self.rootPath = rootPath
    }
    
    /**
     Called when the operation has started
     */
    override func main() {
        
        DataManager.shared.managedObjectContext.performAndWait {
            do
            {
                for item: [String:Any] in self.entries {
                    
                    // Each item requires an id, name, path and tag
                    guard let itemId = item["id"] as? String,
                        let name = item["name"] as? String,
                        let path = item["path_display"] as? String,
                        let tag = item[".tag"] as? String
                    else {
                        // reject this item, and continue iterating through the rest
                        continue
                    }
                    
                    // check to see if we have this item in Core Data
                    let request:NSFetchRequest<DropboxItem> = DropboxItem.fetchRequest()
                    request.predicate = NSPredicate(format: "itemId == %@", itemId )
                    let results = try DataManager.shared.managedObjectContext.fetch(request)
                    
                    var dropboxItem:DropboxItem
                    
                    // if we do, then let's modify it instead
                    if let first = results.first {
                        dropboxItem = first
                    } else {
                        
                        // else insert it
                        guard let entityDescription = NSEntityDescription.entity(forEntityName: "DropboxItem", in:DataManager.shared.managedObjectContext) else {
                            return
                        }
                        
                        dropboxItem = DropboxItem(entity: entityDescription, insertInto: DataManager.shared.managedObjectContext)
                        dropboxItem.itemId = itemId
                    }
                    
                    // set the item's properties from the JSON
                    dropboxItem.path_root = self.rootPath
                    dropboxItem.name = name
                    dropboxItem.path_display = path
                    dropboxItem.tag = tag
                    
                    // folders have no size, so we need to allow for it not being there
                    if let size = item["size"] as? Int32 {
                        dropboxItem.size = size
                    } else {
                        dropboxItem.size = 0
                    }
                    
                }
            
                try DataManager.shared.managedObjectContext.save()
                
            } catch {
                
                UIApplication.showJustOKAlertView(NSLocalizedString("global_error", comment: "Error Title"),
                                                  message: NSLocalizedString("data_error", comment: "Error Message"))
                
            }
        }
    }
}
