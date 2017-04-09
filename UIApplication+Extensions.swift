//
//  UIApplication+Extensions.swift
//  MatchboxDropbox
//
//  Created by Neil Skinner on 08/04/2017.
//  Copyright © 2017 Neil Skinner. All rights reserved.
//

import UIKit

extension UIApplication {
    
    /**
     Returns the top most view controller
     */
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
    
    /**
    Handy method that allows us to pop up a simple, 1 button alert
    - parameter tite: The title to display
    - parameter message: The message to display
     */
    class func showJustOKAlertView(_ title: String, message:String) {
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("global_ok", comment: ""), style: .default, handler: nil))
            
            if let visibleVC = UIApplication.topViewController() {
                visibleVC.present(alert, animated: true, completion: nil)
            }
            
        }
    }
}
