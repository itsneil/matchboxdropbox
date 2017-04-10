//
//  BrowseViewModel.swift
//  MatchboxDropbox
//
//  Created by Neil Skinner on 09/04/2017.
//  Copyright © 2017 Neil Skinner. All rights reserved.
//

import UIKit
import CoreData

/**
 Register this delegate with the class that'll be getting model updates
 */
protocol BrowseDelegate : class {
    
    // the data set has been updated
    func dataUpdated()
    
    // show a loading dialogue on the view
    func loadingStart()
    
    // cancel a loading dialogue on the view
    func loadingFinished()
}

/**
 Viewmodel class that acts between the View and Model as part of MVVM
 */
class BrowseViewModel: NSObject {
    
    var browseAPI = BrowseAPI()
    var path:String = "/"
    
    fileprivate var fetchedResultsController:NSFetchedResultsController<DropboxItem>?
    fileprivate weak var delegate:BrowseDelegate?
    
    // The cursor represents the API state for this path. We store it in case this instance gets dealloc'd
    fileprivate var cursor:String? {
        didSet {
            
            guard let cursor = cursor else {
                // this is nil, so we delete it
                UserDefaults.standard.removeObject(forKey: getCursorKey())
                UserDefaults.standard.synchronize()
                return
            }
            
            UserDefaults.standard.set(cursor, forKey: getCursorKey())
            UserDefaults.standard.synchronize()
        }
    }
    
    // If we have more data (in large directories). We store it in case of deallocation
    fileprivate var hasMore:Bool? {
        didSet {
            
            guard let hasMore = hasMore else {
                // this is nil, so we delete it
                UserDefaults.standard.removeObject(forKey: getHasMoreKey())
                UserDefaults.standard.synchronize()
                return
            }
            
            UserDefaults.standard.set(hasMore, forKey: getHasMoreKey())
            UserDefaults.standard.synchronize()
        }
    }
    
    /**
     the key to store the cursor in
     - returns: The keypath in the UserDefaults to store the cursor
     */
    func getCursorKey() -> String {
        return "cursor\(path)"
    }
    
    /**
     the key to store hasMore in
     - returns: The key in UserDefaults to store hasMore
     */
    func getHasMoreKey() -> String {
        return "more\(path)"
    }
    
    /**
     Sets up this viewmodel with the view and path
     - parameter delegate: The BrowseDelegate (typically a TableView) that'll recieve data updates
     - parameter path: The directory path we are interested in
     */
    func setViewModel(withDelegate delegate: BrowseDelegate, forPath path:String = "/") {
        
        self.delegate = delegate
        self.path = path
        
        // We've already got some data before, so reset the cursor and hasMore from saved and load from cache
        if let existingCursor = UserDefaults.standard.object(forKey: getCursorKey()) as? String,
            let existingHasMore = UserDefaults.standard.object(forKey: getHasMoreKey()) as? Bool {
            self.cursor = existingCursor
            self.hasMore = existingHasMore
        } else {
            delegate.loadingStart()
            self.loadData(fromScratch: true)
        }
        
        
        // set the fetch request based on the path our view is interested in
        let fetchRequest:NSFetchRequest<DropboxItem> = DropboxItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "path_root == %@", path )
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataManager.shared.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController?.delegate = self
        
        try? self.fetchedResultsController?.performFetch()
        
    }
    
    /**
     Removes any core data entities matching the fetch request and call the API from the beginning
     */
    func forceRefresh() {
        self.cursor = nil
        self.hasMore = nil
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = DropboxItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "path_root == %@", path )
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Remove any DropboxItem objects in Core Data matching this root path
        do {
            
            let result = try DataManager.shared.managedObjectContext.fetch(fetchRequest)
            
            // Thread safe removal, without this we get a set was mutated whilst enumerating crash
            DataManager.shared.managedObjectContext.performAndWait {
                for object in result {
                    if let object = object as? DropboxItem {
                        DataManager.shared.managedObjectContext.delete(object)
                    }
                }
            }
            
            delegate?.loadingStart()
            self.loadData(fromScratch: true)
            
        } catch {
            UIApplication.showJustOKAlertView(NSLocalizedString("global_error", comment: "Error Title"),
                                              message: NSLocalizedString("refresh_error", comment: "Error Message"))
        }
        
    }
    
    // MARK: - API Methods
    
    /**
     call the API to load data required by this viewModel
     - parameter fromScratch: true to ignore any cursor or state
     */
    func loadData(fromScratch scratch:Bool? = false) {
        
        if let cursor = cursor, scratch != true {
            
            browseAPI.listFolderContinue(forPath: path, withCursor: cursor) { (success, cursor, more) in
                self.delegate?.loadingFinished()
                guard let cursor = cursor, let more = more, success == true else {
                    
                    UIApplication.showJustOKAlertView(NSLocalizedString("global_error", comment: "Error Title"),
                                                      message: NSLocalizedString("data_error", comment: "Error Message"))
                    
                    return
                }
                
                self.cursor = cursor
                self.hasMore = more
                
            }
            
        } else {
            browseAPI.listFolder(forPath: path) { (success, cursor, more) in
                self.delegate?.loadingFinished()
                guard let cursor = cursor, let more = more, success == true else {
                    
                    UIApplication.showJustOKAlertView(NSLocalizedString("global_error", comment: "Error Title"),
                                                      message: NSLocalizedString("data_error", comment: "Error Message"))
                    
                    return
                }
                
                self.cursor = cursor
                self.hasMore = more
            }
        }
    }
    
    // MARK: - Data Methods
    
    /**
     Fetches an item from the fetched results controller
     - parameter forIndexPath: The indexPath of the item
     - returns: The NSManagedObject of optional type DropboxItem
     */
    func getItem(forIndexPath indexPath:IndexPath) -> DropboxItem? {
        
        return fetchedResultsController?.fetchedObjects?[indexPath.row]
    }
    
    /**
     The amount of sections in the tableView
     - returns: The amount of sections, section 0 is the data, section 1 is load more button
     */
    func getSections() -> Int {
        
        return 2
    }
    
    /**
     Returns the count of objects for the section to the view
     - parameter forSection: The section of the view asking
     - returns: the count of data objects, or if we show a load more button or not
     */
    func getCount(forSection section:Int) -> Int {
        
        if section == 1 {
            return hasMore == true ? 1 : 0
        } else {
            return fetchedResultsController?.fetchedObjects?.count ?? 0
        }
        
    }
    
    /**
     Handles cell selection from the view
     - parameter fromVC: The View Controller the selection came from
     - parameter forIndexPath: The indexPath of the cell selected
     */
    func handleSelection(fromViewController fromVC:UIViewController, forIndexPath indexPath:IndexPath) {
        
        // We have been asked to load more
        if indexPath.section == 1 {
            delegate?.loadingStart()
            self.loadData()
            return
        }
        
        // We need an item from the data, so guard this at the beginning
        guard let item = self.getItem(forIndexPath: indexPath) else {
            UIApplication.showJustOKAlertView(NSLocalizedString("browse_fileTitle", comment: "File Title"),
                                              message: NSLocalizedString("data_error", comment: "File Message"))
            return
        }
        
        // If the item is a file, with an image extension and under 20MB, we can get a thumbnail
        
        if item.tag == "file" {
            
            // 20MB (dropbox limit) = 20971520 bytes, and dropbox allowed file extensions
            if let name = item.name, item.size < 20971520 && ["jpg","jpeg","png","tiff","tif","gif","bmp"].contains(URL(fileURLWithPath: name).pathExtension.lowercased()) {
                
                browseAPI.getThumbnail(forId: item.itemId!, completion: { (image) in
                    
                    if let image = image {
                        UIApplication.showImageAlertView(image)
                    }
                    
                })
                
            } else {
                UIApplication.showJustOKAlertView(NSLocalizedString("browse_fileTitle", comment: "File Title"),
                                                  message: NSLocalizedString("browse_fileMessage", comment: "File Message"))
            }
            return
        }
        else if item.tag == "folder" {    // If the item is a folder, we can navigate into it
            
            if let folderPath = item.path_display,
                let vc = fromVC.storyboard?.instantiateViewController(withIdentifier: BrowseTableViewController.Identifier) as? BrowseTableViewController {
                // Inject the browsed to path into the next view controller and present
                vc.path = folderPath
                fromVC.navigationController?.pushViewController(vc, animated: true)
            }
            
            return
        }
        
        // unsupported tag
        UIApplication.showJustOKAlertView(NSLocalizedString("global_error", comment: "File Title"),
                                          message: NSLocalizedString("unsupported_error", comment: "File Message"))
        
        
    }
    
}

// MARK: - Fetched Results Controller Delegate
extension BrowseViewModel: NSFetchedResultsControllerDelegate {
    
    // Notify the delegate of data updated
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataUpdated()
    }
    
}
