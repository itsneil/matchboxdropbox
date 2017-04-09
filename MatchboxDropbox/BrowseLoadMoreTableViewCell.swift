//
//  BrowseLoadMoreTableViewCell.swift
//  MatchboxDropbox
//
//  Created by Neil Skinner on 09/04/2017.
//  Copyright © 2017 Neil Skinner. All rights reserved.
//

import UIKit

class BrowseLoadMoreTableViewCell: UITableViewCell {
    
    // Storyboard identifier
    static let Identifier = "BrowseLoadMoreTableViewCell_Identifier"
    
    @IBOutlet weak var loadMoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadMoreLabel.text = NSLocalizedString("browse_loadMore", comment: "Load More")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected == true {
            loadMoreLabel.text = NSLocalizedString("global_loading", comment: "Loading")
        } else {
            loadMoreLabel.text = NSLocalizedString("browse_loadMore", comment: "Load More") 
        }
        
    }

}
