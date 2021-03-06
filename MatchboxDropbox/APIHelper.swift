//
//  APIHelper.swift
//  MatchboxDropbox
//
//  Created by Neil Skinner on 08/04/2017.
//  Copyright © 2017 Neil Skinner. All rights reserved.
//

import Foundation

/**
 Class to hold our access token and any other things required by the API
 */
class APIHelper: NSObject {

    static let AccessTokenKey = "AccessTokenKey"
    
    static let shared = APIHelper()
    
    /**
    The oauth access token
    The fact this is stored in the user defaults is *very bad and insecure*, having more time I would
    persist this more securely, i.e in the Keychain.
     */
    var accessToken:String? {
        
        didSet {
            
            guard let accessToken = accessToken else {
                UserDefaults.standard.removeObject(forKey: APIHelper.AccessTokenKey)
                UserDefaults.standard.synchronize()
                return
            }
            
            UserDefaults.standard.set(accessToken, forKey: APIHelper.AccessTokenKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    /**
    pulls the access token from the callback URL
    - parameter url: The URL given to us from dropbox
    - returns: if there is a token within
     */
    func getAccessTokenFrom(oauthUrl url:URL) -> Bool {
        
        guard url.scheme == "matchbox",
            let accessToken = url.fragments["access_token"] else {
                return false
        }
        
        APIHelper.shared.accessToken = accessToken
        return true

    }
    
}
