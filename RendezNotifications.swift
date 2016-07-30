//
//  RendezNotifications.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 7/29/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import UIKit

class RendezNotifications: UIViewController,UITableViewDelegate, UITableViewDataSource {

    /*
        Bout time I got around to making a listview for notifications... now that there are
        actual features that can ALLOW for notifications to even happen.
    
        heh.
        *cries
    */
    var someRendez = [RendezStatus]()
    var someChat = [Chat]()
    var someStatus = [Status]()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var pageViewController: UIPageViewController!
    var pageTitles: NSArray = ["MOI", "MAP", "Fwiends"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func onBackPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    //TABLE STUFF-----TABLE STUFF--------TABLE STUFF--------TABLE STUFF--------TABLE STUFF--------TABLE STUFF--------TABLE STUFF--------
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        return someRendez.count + someChat.count + someStatus.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
           }


}
