//
//  ViewController.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/23/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit

    class ViewController: UIViewController{
        
        @IBOutlet weak var headerLabel: UILabel!
        var pageViewController: UIPageViewController!
        var pageTitles: NSArray = ["MOI", "MAP", "Fwiends"]
        var pageImages: NSArray!

       // @IBOutlet weak var pageController: UIPageControl!
        var vcMe: ContentViewController!
        var vcMap: MapViewController!
        var vcFriends: FriendsActivity!
        var index:Int = 0
        //let delegate = UIApplication.sharedApplication().delegate as! AppDelegate

        var vcNotif: RendezNotifications!
        var vcInRanges : rendezChatInRangeViewController!
        
        override func viewDidLoad()
        {
            super.viewDidLoad()
            
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
                /*
             let prefs:UserDefaults = UserDefaults.standard
             let isLoggedIn:Int = prefs.integer(forKey: "ISLOGGEDIN") as Int
             if(isLoggedIn != 1){
             self.performSegue(withIdentifier: "goto_login", sender: self)
             }
             else{
             let delegate = UIApplication.shared.delegate as! AppDelegate
             
             let username:String = prefs.value(forKey: "USERNAME") as! String
             delegate.window?.rootViewController = self
             //This is the MainActivity.  On creation it will create the 3 view controllers that will be shifted between
             self.vcMe = self.storyboard?.instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
             self.vcMap = self.storyboard?.instantiateViewController(withIdentifier: "Maps") as! MapViewController
             self.vcFriends = self.storyboard?.instantiateViewController(withIdentifier: "Friends") as! FriendsActivity
             
             //Instantiate the frame sizes so they fit in main activity (need to figure out how to autosize them into a subview UIView or UIViewcontroller)
             self.vcMe.view.frame = CGRect(x: 0, y: 0, width: vcMe.view.frame.width, height: vcMe.view.frame.size.height)
             self.vcMap.view.frame = CGRect(x: 0, y: 0, width: vcMap.view.frame.width, height: vcMap.view.frame.size.height)
             self.vcFriends.view.frame = CGRect(x: 0,y: 0, width: vcFriends.view.frame.width, height: vcFriends.view.frame.size.height)
             
             let showname:String = prefs.string(forKey: "SHOWNAME")!
             delegate.letsGetDatSocketRollin(username, showname1: showname)
             if (delegate.yourFriends.count == 0){
             print("remember that you get the friend list in VIEWCONTENTCONTROLLER")
             
             delegate.queryFriends(username)
             
             }
             }
             */
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(true)
            let prefs:UserDefaults = UserDefaults.standard
            let isLoggedIn:Int = prefs.integer(forKey: "ISLOGGEDIN") as Int
            if (isLoggedIn != 1) {
                            print(isLoggedIn)
                self.performSegue(withIdentifier: "goto_login", sender: self)
            }else{

                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    
                    let username:String = prefs.value(forKey: "USERNAME") as! String
                    delegate.window?.rootViewController = self
                    //This is the MainActivity.  On creation it will create the 3 view controllers that will be shifted between
                    self.vcMe = self.storyboard?.instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
                    self.vcMap = self.storyboard?.instantiateViewController(withIdentifier: "Maps") as! MapViewController
                    self.vcFriends = self.storyboard?.instantiateViewController(withIdentifier: "Friends") as! FriendsActivity
                    
                    //Instantiate the frame sizes so they fit in main activity (need to figure out how to autosize them into a subview UIView or UIViewcontroller)
                    self.vcMe.view.frame = CGRect(x: 0, y: 0, width: vcMe.view.frame.width, height: vcMe.view.frame.size.height)
                    self.vcMap.view.frame = CGRect(x: 0, y: 0, width: vcMap.view.frame.width, height: vcMap.view.frame.size.height)
                    self.vcFriends.view.frame = CGRect(x: 0,y: 0, width: vcFriends.view.frame.width, height: vcFriends.view.frame.size.height)
                    
                    let showname:String = prefs.string(forKey: "SHOWNAME")!
                    delegate.letsGetDatSocketRollin(username, showname1: showname)
                    if (delegate.yourFriends.count == 0){
                        print("remember that you get the friend list in VIEWCONTENTCONTROLLER")
                        
                        delegate.queryFriends(username)
                        
                    }
                
                self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
                let startVC = self.viewControllerAtIndex(self.index)
                let viewControllers = NSArray(object: startVC)
                self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
                self.pageViewController.view.frame = CGRect(x: 0, y: 85, width: self.view.frame.width, height: self.view.frame.size.height-85)
                self.addChildViewController(self.pageViewController)
                self.view.addSubview(self.pageViewController.view)
                self.pageViewController.didMove(toParentViewController: self)
            }
        }
        
        func viewControllerAtIndex(_ index: Int) -> UIViewController
        {
            if ((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
                return ContentViewController()
            }
            var vc: UIViewController
            if(index == 0){
                vc = self.vcMe
            }
            else if(index == 1){
                vc = self.vcMap
            }
            else{
                vc = self.vcFriends
            }
            return vc
        }

        @IBOutlet weak var segmentIndex: UISegmentedControl!
        @IBAction func indexChanged(_ sender: UISegmentedControl) {
            switch segmentIndex.selectedSegmentIndex{
            case 0:
                let viewControllers = NSArray(object: self.vcMe)
                self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .forward, animated: true, completion: nil)
                self.index = 0
            case 1:
                let viewControllers = NSArray(object: self.vcMap)
                self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .forward, animated: true, completion: nil)
                self.index = 1
            case 2:
                let viewControllers = NSArray(object: self.vcFriends)
                self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .forward, animated: true, completion: nil)
                self.index = 2
            default:
                break
            }
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
        
        
        
    }
    
