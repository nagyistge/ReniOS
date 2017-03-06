//
//  ContentViewController.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/25/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, showRDelegate{

    @IBOutlet weak var bSend: UIButton!
    @IBOutlet weak var bNewRendez: UIButton!
    @IBOutlet weak var friendTableView: UITableView!

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var midLabel: UILabel!
    var items: [String] = ["We", "Heart", "Swift"]
    var someInts = [Status]()
    var someFriendInts = [Status]()
    var statusToPass: Status!
    var newCar: String = ""
    var vc: showR!
    var username:String!
    var onsend:onSendRendezList!
    
    @IBOutlet weak var tableView: UITableView!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.friendTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell1")
        let prefs:UserDefaults = UserDefaults.standard
        let isLoggedIn:Int = prefs.integer(forKey: "ISLOGGEDIN") as Int
        if(isLoggedIn != 1){
            self.dismiss(animated: true, completion: nil)
        }
        username = prefs.value(forKey: "USERNAME") as! String
        if (self.delegate.theWozMap[username] == nil){
            self.delegate.starting()
        }

        self.someInts.append( contentsOf: self.delegate.theWozMap[username]!.allDeesStatus )
        self.someFriendInts.append(contentsOf: self.delegate.newfeed)
        self.view.backgroundColor = UIColor.rgb(235, green: 235, blue: 235)
        print("")
        print("ContentViewController:: viewDidLoad()")
        print("")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("")
        print("")
        print("ContentViewController:: viewDidAppear()")
        print("  ", self.view.frame)
        print("")
        print("")
        let prefs:UserDefaults = UserDefaults.standard
        let username:String = prefs.value(forKey: "USERNAME") as! String
        let width = UIScreen.main.bounds.size.width
        let delegate1 = UIApplication.shared.delegate as! AppDelegate
        // top label + offset + midlabel + buttonoffset + button height
        //  30 + 5 + 30 + 10 + 16 + 60
        let tableViewTotalHeight = self.view.frame.size.height-151
        let topheight = tableViewTotalHeight*(3/5) as CGFloat
        let botheight = tableViewTotalHeight*(2/5) as CGFloat
        // top label height = 30
        self.tableView.frame = CGRect(origin: CGPoint(x: 5, y: 35 ), size: CGSize(width: width-10, height: topheight ))
        //   35 + 5 because top label height is 30 and 5 for a bit of buffer
        self.midLabel.frame = CGRect(origin: CGPoint(x: 0, y: (35)+self.tableView.frame.size.height ), size: CGSize(width: self.midLabel.frame.size.width, height: 30 ))
        
        // topheight+65 since origin needs to be below top tableview+labels
        self.friendTableView.frame = CGRect(x: 5, y: topheight+(65), width: width-10, height: botheight)
        
        self.tableView.layer.cornerRadius = 10
        self.friendTableView.layer.cornerRadius = 10
        // 10px buffer between buttons and friendTableView, currently at view.height-180
        
        // height 60 width 150/ origin height = view.height-170
        self.bNewRendez.frame = CGRect(origin: CGPoint(x: 20 , y: self.view.frame.size.height-80 ) , size: CGSize(width: 150, height: 60 ))
        self.bSend.frame = CGRect(origin: CGPoint(x: self.view.frame.size.width-170 , y: self.view.frame.size.height-80 ) , size: CGSize(width: 150, height: 60 ))
        
        self.someInts.removeAll()
        self.someFriendInts.removeAll()
        self.someInts.append( contentsOf: delegate1.theWozMap[username]!.allDeesStatus )
        self.someFriendInts.append(contentsOf: delegate1.newfeed)
        self.tableView.reloadData()
        self.friendTableView.reloadData()

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // 1
        return 1
    }
    
    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        if tableView == self.tableView{
            return self.someInts.count
        }else{
            return self.someFriendInts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 3
        if tableView == self.tableView{
            let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 17)
            cell.textLabel!.text = self.someInts[indexPath.row].title
            let status = self.someInts[indexPath.row]
            var v = ""
            if(self.someInts[indexPath.row].visable == 0){
                v += "private"
            }else{
                v += "public"
            }
            v += "\n" + status.timefor
            cell.detailTextLabel!.text = v
        
            if(status.type == 0){
                cell.imageView?.image = UIImage(named: "eat")
            }else if(status.type == 1){
                cell.imageView?.image = UIImage(named: "party")
            }else if(status.type == 2){
                cell.imageView?.image = UIImage(named: "working")
            }else if(status.type == 3){
                cell.imageView?.image = UIImage(named: "idle")
            }
            //cell.backgroundColor = UIColor.rgb(235, green: 235, blue: 235)
        return cell
        }
        else{
            let friendcell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell1")
            friendcell.selectionStyle = UITableViewCellSelectionStyle.none
            friendcell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            friendcell.textLabel!.text = self.someFriendInts[indexPath.row].title
            let status = self.someFriendInts[indexPath.row]

            friendcell.detailTextLabel!.text = "from " + self.someFriendInts[indexPath.row].username + "\n" + status.timefor
        
            if(status.type == 0){
                friendcell.imageView?.image = UIImage(named: "eat")
            }else if(status.type == 1){
                friendcell.imageView?.image = UIImage(named: "party")
            }else if(status.type == 2){
                friendcell.imageView?.image = UIImage(named: "working")
            }else if(status.type == 3){
                friendcell.imageView?.image = UIImage(named: "idle")
            }
            //friendcell.backgroundColor = UIColor.rgb(235, green: 235, blue: 235)
            return friendcell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        if tableView == self.tableView{
            let currentCell = self.someInts[indexPath.row] as Status
            statusToPass = currentCell
            vc = self.storyboard?.instantiateViewController(withIdentifier: "showR") as! showR
            vc.programVar = statusToPass
            vc.isStatusFromYou = true
            vc.returnDelegate = self
            self.present(vc, animated: true, completion: nil)
        }else{
            let currentCell = self.someFriendInts[indexPath.row] as Status
            statusToPass = currentCell
            vc = self.storyboard?.instantiateViewController(withIdentifier: "showR") as! showR
            vc.programVar = statusToPass
            vc.isStatusFromYou = false
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func newR(_ sender: AnyObject) {
    }

    func returnUpdate(_ status:Status){
        let prefs:UserDefaults = UserDefaults.standard
        let username:String = prefs.value(forKey: "USERNAME") as! String
        let delegate1 = UIApplication.shared.delegate as! AppDelegate
        self.someInts.removeAll()
        self.someFriendInts.removeAll()
        self.someInts.append( contentsOf: delegate1.theWozMap[username]!.allDeesStatus )
        self.someFriendInts.append(contentsOf: delegate1.newfeed)
        self.tableView.reloadData()
        self.friendTableView.reloadData()
    }
    
    @IBAction func onSend(_ sender: UIButton) {
        onsend = self.storyboard?.instantiateViewController(withIdentifier: "onSend") as! onSendRendezList
        onsend.rendez.append(contentsOf: self.someInts)
        onsend.friends.append(contentsOf: ( UIApplication.shared.delegate as! AppDelegate).yourFriends)
        onsend.groups.append(contentsOf: ( UIApplication.shared.delegate as! AppDelegate).yourGroups)
        self.present(onsend, animated: true, completion: nil)
    }


}
