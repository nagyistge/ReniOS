//
//  ViewController.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/23/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit

    class ViewController: UIViewController{
        @IBOutlet weak var bSetting: UIButton!
        @IBOutlet weak var bNotif: UIButton!
        @IBOutlet weak var bRendë: UIButton!
        @IBOutlet weak var statusLabel: UILabel!
        @IBOutlet weak var headerLabel: UILabel!
        var pageViewController: UIPageViewController!
        var pageTitles: NSArray = ["MOI", "MAP", "Fwiends"]
        var pageImages: NSArray!
        @IBOutlet weak var segmentIndex: UISegmentedControl!
       // @IBOutlet weak var pageController: UIPageControl!
        var vcMe: ContentViewController?
        var vcMap: MapViewController?
        var vcFriends: FriendsActivity?
        
        var index:Int = 0
        //let delegate = UIApplication.sharedApplication().delegate as! AppDelegate

        var vcNotif: RendezNotifications!
        var vcInRanges : rendezChatInRangeViewController!
        //let keyFrame = UIScreen.main.bounds
        override func viewDidLoad()
        {
            super.viewDidLoad()
            //headerLabel.frame = CGRect(origin: .zero, size: CGSize(width: keyFrame.width, height: 50))
            print("")
            print("ViewController:: viewDidLoad()")

                // Re-frame all the views because storyboard sucks
                let w = UIScreen.main.bounds.size.width
                
                self.bSetting.frame = CGRect(origin: CGPoint(x: w-70, y: 20.0 ), size: CGSize(width: 70, height: 40) )//, size: <#T##CGSize#>
                self.bNotif.frame = CGRect(origin: CGPoint(x: w-(140), y: 20.0 ), size: CGSize(width: 70, height: 40) )
                self.bRendë.frame = CGRect(origin: CGPoint(x: w-(210), y: 20.0 ), size: CGSize(width: 70, height: 40) )
                self.bSetting.layer.borderWidth = 1
                self.bNotif.layer.borderWidth = 1
                self.bRendë.layer.borderWidth = 1
                self.bSetting.layer.borderColor = UIColor.rgb(0, green: 200, blue: 100).cgColor
                self.bNotif.layer.borderColor = UIColor.rgb(0, green: 200, blue: 100).cgColor
                self.bRendë.layer.borderColor = UIColor.rgb(0, green: 200, blue: 100).cgColor
                
                self.statusLabel.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 20 ))
                self.headerLabel.frame = CGRect(origin: CGPoint(x: 0, y: 20.0 ), size: CGSize(width: UIScreen.main.bounds.size.width, height: 40))
                self.segmentIndex.frame = CGRect(origin: CGPoint(x: -10.0, y: 60.0), size: CGSize(width: w+20, height: self.segmentIndex.frame.size.height ))
                print("UIScreen.main.bounds ",UIScreen.main.bounds)
                
                //This is the MainActivity.  On creation it will create the 3 view controllers that will be shifted between
                self.vcMe = self.storyboard?.instantiateViewController(withIdentifier: "ContentViewController") as? ContentViewController
                self.vcMap = self.storyboard?.instantiateViewController(withIdentifier: "Maps") as? MapViewController
                self.vcFriends = self.storyboard?.instantiateViewController(withIdentifier: "Friends") as? FriendsActivity
                let pageHeight = self.view.frame.size.height-(60+self.segmentIndex.frame.size.height)
                print("view height/pageHeight ", self.view.frame.size.height, pageHeight)
                //Instantiate the frame sizes so they fit in main activity (need to figure out how to autosize them into a subview UIView or UIViewcontroller)
                self.vcMe?.view.frame = CGRect(x: 0, y: 0, width: w, height: pageHeight)
                self.vcMap?.view.frame = CGRect(x: 0, y: 0, width: w, height: pageHeight)
                self.vcFriends?.view.frame = CGRect(x: 0,y: 0, width: w, height: pageHeight)
            print("ViewController:: self.vcMe(AKA ContentViewController) frame resized smaller.", self.vcMe?.view.frame ?? "")
        
            self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
            
            self.pageViewController.view.frame = CGRect(x: 0, y: 60+self.segmentIndex.frame.size.height, width: self.view.frame.width, height: self.view.frame.size.height-(60+self.segmentIndex.frame.size.height))
            // set viewControllers for presents
            self.vcFriends?.viewController = self
            self.vcMe?.viewController = self
            self.vcMap?.viewController = self
            
            self.view.addSubview(self.pageViewController.view)
            print("ViewController:: viewDidLoad() finish")
            print("")
            let prefs:UserDefaults = UserDefaults.standard
            let isLoggedIn:Int = prefs.integer(forKey: "ISLOGGEDIN") as Int
            if (isLoggedIn != 1) {
                print(isLoggedIn)
                self.performSegue(withIdentifier: "goto_login", sender: self)
            }else{
                let delegate = UIApplication.shared.delegate as! AppDelegate
                let username:String = prefs.value(forKey: "USERNAME") as! String
                delegate.window?.rootViewController = self
            // R_me all the views because storyboard sucks
            
                print("ViewController:: viewDidAppear()")
                print("")
            
                let showname:String = prefs.string(forKey: "SHOWNAME")!
                delegate.letsGetDatSocketRollin(username, showname1: showname)
                
                if (delegate.yourFriends.count == 0){
                    print("remember that you get the friend list in VIEWCONTENTCONTROLLER")
                    delegate.queryFriends(username)
                }
            }
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(true)
            let prefs:UserDefaults = UserDefaults.standard
            let isLoggedIn:Int = prefs.integer(forKey: "ISLOGGEDIN") as Int
            if (isLoggedIn != 1) {
                            print(isLoggedIn)
                self.performSegue(withIdentifier: "goto_login", sender: self)
            }else{
                
                // Re-frame all the views because storyboard sucks
               // let w = UIScreen.main.bounds.size.width

                print("ViewController:: viewDidAppear()")
                print("")


                print("ViewController::viewDidAppear(): self.vcMe(AKA ContentViewController) frame resized smaller.", self.vcMe!.view.frame)

                //let startVC = self.viewControllerAtIndex(self.index)
                //let startVC = self.vcMe
                let viewControllers = NSArray(object: self.vcMe! )
                
                print("ViewController:: viewDidAppear() finish")
                print("")
                if self.pageViewController.viewControllers?.count == 0{
                    self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .forward, animated: true, completion: nil)
                }
            }
        }
        
        func viewControllerAtIndex(_ index: Int) -> UIViewController
        {
            if ((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
                print("is it this?????")
                return ContentViewController()
            }
            var vc: UIViewController
            if(index == 0){
                
                vc = self.vcMe!
            }
            else if(index == 1){
                vc = self.vcMap!
            }
            else{
                vc = self.vcFriends!
            }
            return vc
        }

        @IBAction func indexChanged(_ sender: UISegmentedControl) {
            //var direction:UIPageViewControllerNavigationDirection = .
            let direction = getDirection(old: self.index, new: segmentIndex.selectedSegmentIndex)
            var viewControllers = [UIViewController]()
            switch segmentIndex.selectedSegmentIndex{
            case 0:
                //let viewControllers = NSArray(object: self.vcMe)
                viewControllers.append(self.vcMe!)
                self.index = 0
            case 1:
                //let viewControllers = NSArray(object: self.vcMap)
                viewControllers.append(self.vcMap!)
                self.index = 1
            case 2:
                //let viewControllers = NSArray(object: self.vcFriends)
                viewControllers.append(self.vcFriends!)
                self.index = 2
            default:
                break
            }
            self.pageViewController.setViewControllers(viewControllers,direction: direction, animated: true, completion: nil)
        }

        func presentationCountForPageViewController(_ pageViewController: UIPageViewController) -> Int
        {
            return self.pageTitles.count
        }
        
        func presentationIndexForPageViewController(_ pageViewController: UIPageViewController) -> Int
        {
            return 0
        }
        
        
        //on Button for Notificaions
        @IBAction func onNotificationPress(_ sender: UIButton) {
            vcNotif = self.storyboard?.instantiateViewController(withIdentifier: "rendezNotifications") as! RendezNotifications
            self.present(vcNotif, animated: true, completion: nil)
        }
        
        //on Button for Ranges
        @IBAction func onInRanges(_ sender: UIButton) {
            vcInRanges = self.storyboard?.instantiateViewController(withIdentifier: "rendezInRange") as! rendezChatInRangeViewController
            let delegate = UIApplication.shared.delegate as! AppDelegate
            vcInRanges.rendezes = delegate.r_rendezstatus
            vcInRanges.statuses = delegate.r_status
            self.present(vcInRanges, animated: true, completion: nil)
            
        }
        
        func getDirection(old:Int,new:Int ) -> UIPageViewControllerNavigationDirection{
            if old < new{
                return UIPageViewControllerNavigationDirection.forward
            }else{
                return UIPageViewControllerNavigationDirection.reverse
            }
            //return UIPageViewControllerNavigationDirection.forward
        }
    }
    
