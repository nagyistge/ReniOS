//
//  PageContentViewController.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/25/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController {
    

    
    var pageIndex: Int?
    var titleText : String!
    var imageName : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bkImageView.image = UIImage(named: imageName)
        self.heading.text = self.titleText
        self.heading.alpha = 0.1
        UIView.animateWithDuration(1.0, animations: { () -> Void in self.heading.alpha = 1.0
        })
        
    }
}
