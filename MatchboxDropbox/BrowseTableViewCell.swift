//
//  BrowseTableViewCell.swift
//  MatchboxDropbox
//
//  Created by Neil Skinner on 09/04/2017.
//  Copyright © 2017 Neil Skinner. All rights reserved.
//

import UIKit

class BrowseTableViewCell: UITableViewCell {
    
    // Storyboard identifier
    static let Identifier = "BrowseTableViewCell_Identifier"
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellSizeLabel: UILabel!
    @IBOutlet weak var cellTitleLabel: UILabel!

    /**
    Decorate the cell when the item is set
     */
    weak var item:DropboxItem? {
        didSet {
            
            guard let item = item else {
                print ("This tableview cell cannot decorate blank")
                return
            }
            
            self.cellTitleLabel.text = item.name ?? ""
            
            if item.tag == "folder" {
                self.cellImageView.image = UIImage(named:"ic_folder")
                self.cellSizeLabel.isHidden = true
                self.accessoryType = .disclosureIndicator
                self.selectionStyle = .default
                
            } else {
                self.cellImageView.image = UIImage(named:"ic_file")
                self.cellSizeLabel.isHidden = false
                self.cellSizeLabel.text = "\(item.size) \(NSLocalizedString("global_bytes", comment: "bytes"))"
                self.accessoryType = .none
                self.selectionStyle = .none
            }
        }
    }
}
