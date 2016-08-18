//
//  onSendCell.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/14/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import UIKit

class onSendCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.makeItCircle()
    }
    
    func makeItCircle() {
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.cornerRadius  = CGFloat(roundf(Float(self.imageView.frame.size.width/2.0)))
    }



}
