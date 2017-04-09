//
//  LoginAPI.swift
//  MatchboxDropbox
//
//  Created by Neil Skinner on 08/04/2017.
//  Copyright © 2017 Neil Skinner. All rights reserved.
//

import UIKit
import CoreData

/**
 Class that handles the oauth things.
 Login is not technically an API, since it calls a remote website and gets a token back
 so it could have a better name :)
 */
class LoginAPI: NSObject {
    
    // We will only need one of these, so singleton
    static let shared = LoginAPI()
    
    let oathAuthUrlString = "https://www.dropbox.com/1/oauth2/authorize?client_id=ma448cd8i69gdbn&response_type=token&redirect_uri=matchbox://redirect/"
    
    let signOutUrlString = "https://api.dropboxapi.com/2/auth/token/revoke"
    
    /**
     Get the dropbox external auth url
     - returns: the dropbox oauth in URL form
     */
    func getOauthAuthUrl() -> URL? {
        return URL(string: oathAuthUrlString)
    }
    
    /**
     Invalidates the user token and clears the data store for a logout
     - parameter success: If we are successfully logged out
     */
    func doSignOut(completion: @escaping (_ success: Bool) -> Void) {
        guard let url = URL(string: self.signOutUrlString),
            let accessToken = APIHelper.shared.accessToken else {
                completion(false)
                return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                completion(false)
                return
            }
            
            // If we have invalidated the token, we need to clear our local data out
            let fetchRequest:NSFetchRequest<NSFetchRequestResult> = DropboxItem.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            do {
                let result = try DataManager.shared.managedObjectContext.fetch(fetchRequest)
                for object in result {
                    if let object = object as? DropboxItem {
                        DataManager.shared.managedObjectContext.delete(object)
                    }
                }

            } catch {
                // we can be quiet here, but going forward should handle gracefully
            }
            completion(true)
            
            
            }.resume()
    }
}
