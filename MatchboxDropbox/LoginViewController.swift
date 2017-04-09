//
//  LoginViewController.swift
//  MatchboxDropbox
//
//  Created by Neil Skinner on 08/04/2017.
//  Copyright © 2017 Neil Skinner. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // Storyboard identifier
    static let Identifier = "LoginViewController_Identifier"
    
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.setTitle(NSLocalizedString("button_signIn", comment: "Sign in button"), for: .normal)
        signInButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // we have an access token, so can log ourselves in.
        // This is done in viewDidAppear to allow any animations to finish.
        if let _ = APIHelper.shared.accessToken,
            let browseNavigationController = UIStoryboard(name: "Browse", bundle: nil).instantiateViewController(withIdentifier: BrowseNavigationController.Identifier) as? BrowseNavigationController {
            self.present(browseNavigationController, animated: true, completion: nil)
        } else {
            signInButton.isHidden = false
        }
    }
    
    @IBAction func didTapSignInButton(_ sender: Any) {
        
        guard let oauthUrl = LoginAPI.shared.getOauthAuthUrl(), UIApplication.shared.canOpenURL(oauthUrl) else {
            
            let alert = UIAlertController(title: NSLocalizedString("global_error", comment: "Error Title"),
                                          message: NSLocalizedString("global_catastrophicMessage", comment: "Error Message"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("global_ok", comment: "OK"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
            
        }
        
        UIApplication.shared.open(oauthUrl, options: [:], completionHandler: nil)
        
    }
}
