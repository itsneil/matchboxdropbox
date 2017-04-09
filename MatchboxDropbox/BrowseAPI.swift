//
//  BrowseAPI.swift
//  MatchboxDropbox
//
//  Created by Neil Skinner on 08/04/2017.
//  Copyright © 2017 Neil Skinner. All rights reserved.
//

import UIKit

/**
 Class to handle the API requests to list folder information
 Not a singleton as each Viewmodel holds it's own reference configured with it's own path, cursor etc
 */
class BrowseAPI: NSObject {
    
    let listFolderUrlString = "https://api.dropboxapi.com/2/files/list_folder"
    let listFolderContinueUrlString = "https://api.dropboxapi.com/2/files/list_folder/continue"
    
    /**
    Calls the dropbox list_folder endpoint
    - parameter path: The path we are interested in
    - parameter success: If the request was successful
    - parameter cursor: The state cursor returned from the API
    - parameter more: If there is more data that we can load
     */
    func listFolder(forPath path:String, completion: @escaping (_ success: Bool, _ cursor: String?, _ more: Bool?) -> Void) {
        
        // If we have no valid URL or token we cannot continue
        guard let url = URL(string: self.listFolderUrlString),
            let accessToken = APIHelper.shared.accessToken else {
            completion(false, nil, nil)
            return
        }
        
        // Build the URLRequest with the required headers and body
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // Dropbox api requires the root's path as an empty string
            request.httpBody = try JSONSerialization.data(withJSONObject: ["path":(path == "/" ? "" : path)], options: [])
        } catch {
            completion(false, nil, nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // We need no error, data, JSON and an array of entries, a cursor string and a boolean indicating more
            guard error == nil,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any],
                let entries = json?["entries"] as? [[String:Any]],
                let cursor = json?["cursor"] as? String,
                let hasMore = json?["has_more"] as? Bool
            else {
                completion(false, nil, nil)
                return
            }
            
            // Send the entries to the operation queue to be imported into Core Data
            DataManager.shared.coreDataOperationQueue.addOperation(ImportOperation(rootPath: path, entries: entries))
            
            completion(true, cursor, hasMore)
            
        }.resume()
    
    }
    
    /**
     Calls the dropbox list_folder/continue endpoint
     - parameter path: The path we are interested in
     - parameter withCursor: Our saved cursor for the above path
     - parameter success: If the request was successful
     - parameter cursor: The state cursor returned from the API
     - parameter more: If there is more data that we can load
     */
    func listFolderContinue(forPath path:String, withCursor cursor:String, completion: @escaping (_ success: Bool, _ cursor: String?, _ more: Bool?) -> Void) {
        
        // If we have no valid URL or token we cannot continue
        guard let url = URL(string: self.listFolderContinueUrlString),
            let accessToken = APIHelper.shared.accessToken else {
                completion(false, nil, nil)
                return
        }
        
        // Build the URLRequest with the required headers and body
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: ["cursor":cursor], options: [])
        } catch {
            completion(false, nil, nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // We need no error, data, JSON and an array of entries, a cursor string and a boolean indicating more
            guard error == nil,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any],
                let entries = json?["entries"] as? [[String:Any]],
                let cursor = json?["cursor"] as? String,
                let hasMore = json?["has_more"] as? Bool
                else {
                    completion(false, nil, nil)
                    return
            }
            
            // Send the entries to the operation queue to be imported into Core Data
            DataManager.shared.coreDataOperationQueue.addOperation(ImportOperation(rootPath: path, entries: entries))
            
            completion(true, cursor, hasMore)
            
            }.resume()
        
    }
}
