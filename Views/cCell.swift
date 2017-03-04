//
//  cCell.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/5/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import UIKit

class cCell: UITableViewCell {

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var cTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
