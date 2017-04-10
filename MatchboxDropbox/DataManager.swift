//
//  DataManager.swift
//  MatchboxDropbox
//
//  Created by Neil Skinner on 09/04/2017.
//  Copyright © 2017 Neil Skinner. All rights reserved.
//

import UIKit
import CoreData

/**
 Class that holds references to our Core Data managedObjectContext and import queue
 */
class DataManager: NSObject {
    
    static let shared = DataManager()
    
    var managedObjectContext:NSManagedObjectContext {
        get {
            // we only need to use the main app one in this instance.
            return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        }
    }
    
    // operation queue of size 1 to prevent concurrency issues
    lazy var coreDataOperationQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "coreDataOperationQueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
}
