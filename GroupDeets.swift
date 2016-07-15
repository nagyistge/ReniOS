//
//  GroupDeets.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 7/15/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import UIKit

class GroupDeets: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var gname: UILabel!
    @IBOutlet weak var gdeets: UILabel!
    
    var someInts:[Friend] = []
    var name:String!
    var deet:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        gname.text = name
        gdeets.text = deet
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onBackPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        return self.someInts.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        NSLog("Checking if the uitable in friendsactivity gets called before or after");
        // 3
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
       cell.textLabel?.text = someInts[indexPath.row].friendname
        return cell
    }

}
