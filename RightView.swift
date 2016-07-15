//
//  RightView.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 7/15/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import UIKit

class RightView: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
