//
//  BrowseTableViewController.swift
//  MatchboxDropbox
//
//  Created by Neil Skinner on 09/04/2017.
//  Copyright © 2017 Neil Skinner. All rights reserved.
//

import UIKit

class BrowseTableViewController: UITableViewController {
    
    // Storyboard identifier
    static let Identifier = "BrowseTableViewController_Identifier"
    
    var path:String = "/"
    
    fileprivate var viewModel = BrowseViewModel()
    fileprivate var loadingDialogue:UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
        self.title = path
        self.viewModel.setViewModel(withDelegate: self, forPath: path)

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If we're the only view controller on the stack, we're at the root so show a signout button
        if self.navigationController?.childViewControllers.count == 1 {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("global_signout", comment: "Sign Out"), style: .plain, target: self, action: #selector(doSignOut))
        }
        
    }
    
    func refreshData() {
        self.refreshControl?.endRefreshing()
        
        // 0.5 second delay allows the refresh control to finish it's UI business before we blast the data
        let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.global().asyncAfter(deadline: delayTime, execute: {
            self.viewModel.forceRefresh()
        })
    }
    
    /**
     called when the user wishes to sign out
     */
    func doSignOut() {
        LoginAPI.shared.doSignOut { (success) in
            
            if success == true {
                APIHelper.shared.accessToken = nil
                
                if let bundle = Bundle.main.bundleIdentifier {
                    UserDefaults.standard.removePersistentDomain(forName: bundle)
                    UserDefaults.standard.synchronize()
                }
                
                self.dismiss(animated: true, completion: nil)
            } else {
                UIApplication.showJustOKAlertView(NSLocalizedString("global_error", comment: "Error Title"),
                                                  message: NSLocalizedString("signout_error", comment: "Error Message"))
                
            }
            
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getCount(forSection: section)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.getSections()
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // section 1 is the load more cell
        if indexPath.section == 1 {
            return tableView.dequeueReusableCell(withIdentifier: BrowseLoadMoreTableViewCell.Identifier) ?? UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: BrowseTableViewCell.Identifier, for: indexPath) as?    BrowseTableViewCell
            cell?.item = self.viewModel.getItem(forIndexPath: indexPath)
            return cell ?? UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.viewModel.handleSelection(fromViewController: self, forIndexPath: indexPath)
        
    }
    
}

// MARK: - Browse View Model Delegate
extension BrowseTableViewController: BrowseDelegate {
    
    /**
     Refresh the tableview as the data has changed
     */
    func dataUpdated() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    /**
     Show a loading message
     */
    func loadingStart() {
        
        if self.loadingDialogue != nil {
            return
        }
        
        self.loadingDialogue = UIAlertController(title: NSLocalizedString("global_loading", comment: "Loading"), message: nil, preferredStyle: .alert)
        
        guard let loadingDialogue = self.loadingDialogue else {
            return
        }
        
        DispatchQueue.main.async {
            self.present(loadingDialogue, animated: true, completion: nil)
        }
        
    }
    
    /**
     Hide a loading message
     */
    func loadingFinished() {
        
        // Delay of 0.5 seconds to allow any animations to finish
        if let loadingDialogue = self.loadingDialogue {
            let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                loadingDialogue.dismiss(animated: true, completion: nil)
                self.loadingDialogue = nil
                
            })
        }        
    }
    
}
