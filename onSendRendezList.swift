//
//  onSendRendezList.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/14/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import UIKit

extension UIColor {
    class func randomColor() -> UIColor {
        
        let hue = CGFloat(arc4random() % 100) / 100
        let saturation = CGFloat(arc4random() % 100) / 100
        let brightness = CGFloat(arc4random() % 100) / 100
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}

func generateRandomData() -> [[UIColor]] {
    let numberOfRows = 20
    let numberOfItemsPerRow = 15
    
    return (0..<numberOfRows).map { _ in
        return (0..<numberOfItemsPerRow).map { _ in UIColor.randomColor() }
    }
}

class onSendRendezList: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var collection1: UICollectionView!
    @IBOutlet weak var collection2: UICollectionView!
    
    let model: [[UIColor]] = generateRandomData()
    
    var rendez: [Status] = []
    var friends: [Friend] = []
    
    var username:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.collection1.registerClass(onSendCell.self, forCellWithReuseIdentifier: "cell4")
        //self.collection2.registerClass(onSendCell2.self, forCellWithReuseIdentifier: "cell5")
        
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        username = prefs.valueForKey("USERNAME") as! String
let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        print(username)
        
        //self.rendez.appendContentsOf(delegate.theWozMap[username]!.allDeesStatus)
        self.friends.appendContentsOf(delegate.yourFriends)
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.friends.appendContentsOf(delegate.yourFriends)
        
        self.collection1.reloadData()
        self.collection2.reloadData()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            if(collectionView == collection1){
                return self.friends.count
            }else{
                return self.rendez.count
            }
            //return model[collectionView.tag].count
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            if(collectionView == self.collection1){
                let cell = self.collection1.dequeueReusableCellWithReuseIdentifier("cell4", forIndexPath: indexPath) as! onSendCell

                cell.backgroundColor = UIColor.blackColor()
                cell.title.text? = self.friends[indexPath.row].username
                return cell
            }else{
                let cell = self.collection2.dequeueReusableCellWithReuseIdentifier("cell5", forIndexPath: indexPath) as! onSendCell2

                cell.backgroundColor = UIColor.redColor()
                
                print(self.rendez[indexPath.row].title)
                
                cell.title.text = self.rendez[indexPath.row].title
                return cell

            }
            
    }


}
