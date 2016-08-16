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
    
    var rendez = [Status]()
    var friends = [Friend]()
    
    var username:String!
    
    @IBOutlet weak var titlee: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var location: UILabel!
    
     var path: NSIndexPath!
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.collection1.registerClass(onSendCell.self, forCellWithReuseIdentifier: "cell4")
        //self.collection2.registerClass(onSendCell2.self, forCellWithReuseIdentifier: "cell5")
        let longpress = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")
        self.collection2.addGestureRecognizer(longpress)
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        username = prefs.valueForKey("USERNAME") as! String
let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        print(username)
        
        //self.rendez.appendContentsOf(delegate.theWozMap[username]!.allDeesStatus)
        //self.friends += delegate.yourFriends
        self.collection1.reloadData()
        self.collection2.reloadData()
        // Do any additional setup after loading the view.
    }
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //self.friends += (delegate.yourFriends)
        
        self.collection1.reloadData()
        self.collection2.reloadData()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.locationInView(self.collection2)
        //let indexPath = collection2.indexPathForRowAtPoint(locationInView)
        let indexPath = collection2.indexPathForItemAtPoint(locationInView)
        
        struct My {
            static var cellSnapshot : UIView? = nil
            static var cellIsAnimating : Bool = false
            static var cellNeedToShow : Bool = false
        }
        struct Path {
            static var initialIndexPath : NSIndexPath? = nil
        }
        
        var cell: UICollectionViewCell!
       
        switch state {
        case UIGestureRecognizerState.Began:
            print("is it here?")
            if indexPath != nil {
                Path.initialIndexPath = indexPath
                //let cell = tableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
                path = indexPath!
                cell = self.collection2.cellForItemAtIndexPath(indexPath!) as UICollectionViewCell!
                My.cellSnapshot  = snapshotOfCell(cell)
                
                var center = cell.center
                My.cellSnapshot!.center = locationInView
                //center
                My.cellSnapshot!.alpha = 0.0
                
                self.view.addSubview(My.cellSnapshot!)
                //tableView.addSubview(My.cellSnapshot!)
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    center.y = locationInView.y
                    My.cellIsAnimating = true
                    My.cellSnapshot!.center = center
                    My.cellSnapshot!.transform = CGAffineTransformMakeScale(1.05, 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell.alpha = 0.1
                    }, completion: { (finished) -> Void in
                        if finished {
                            My.cellIsAnimating = false
                            if My.cellNeedToShow {
                                My.cellNeedToShow = false
                                UIView.animateWithDuration(0.25, animations: { () -> Void in
                                    cell.alpha = 1
                                })
                            } else {
                                cell.hidden = true
                            }
                        }
                })
            }
            
        case UIGestureRecognizerState.Changed:
            if My.cellSnapshot != nil {
                var center = My.cellSnapshot!.center
                center.y = locationInView.y
                My.cellSnapshot!.center = center
                
                /*
                if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
                    itemsArray.insert(itemsArray.removeAtIndex(Path.initialIndexPath!.row), atIndex: indexPath!.row)
                    tableView.moveRowAtIndexPath(Path.initialIndexPath!, toIndexPath: indexPath!)
                    Path.initialIndexPath = indexPath
                }*/
            }
        default:
            print("default")
            
            if Path.initialIndexPath != nil {
                //let cell = tableView.cellForRowAtIndexPath(Path.initialIndexPath!) as UITableViewCell!
                cell = self.collection2.cellForItemAtIndexPath(path!) as UICollectionViewCell!
                if My.cellIsAnimating {
                    My.cellNeedToShow = true
                } else {
                    cell.hidden = false
                    cell.alpha = 0.0
                }
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    My.cellSnapshot!.center = cell.center
                    My.cellSnapshot!.transform = CGAffineTransformIdentity
                    My.cellSnapshot!.alpha = 0.0
                    cell.alpha = 1.0
                    
                    }, completion: { (finished) -> Void in
                        if finished {
                            Path.initialIndexPath = nil
                            My.cellSnapshot!.removeFromSuperview()
                            My.cellSnapshot = nil
                        }
                })
            }
            
        }
    }
    
    func snapshotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
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

                cell.backgroundColor = UIColor.greenColor()
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
    
    
    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            if(collectionView == self.collection2){
                self.titlee.text = self.rendez[indexPath.row].title
                self.detail.text = self.rendez[indexPath.row].detail
                self.location.text = self.rendez[indexPath.row].location
            }
    }


}
