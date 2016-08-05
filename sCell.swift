//
//  sCell.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/5/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import UIKit

class sCell: UITableViewCell {
    @IBOutlet weak var sTitle: UILabel!

    @IBOutlet weak var time: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
