//
//  ViewController.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 8/23/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import UIKit

    class ViewController: UIViewController{
        
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
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
            if(isLoggedIn != 1){
                self.performSegueWithIdentifier("goto_login", sender: self)
            }
            else{
                let username:String = prefs.valueForKey("USERNAME") as! String
                //This is the MainActivity.  On creation it will create the 3 view controllers that will be shifted between
                self.vcMe = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ContentViewController
                self.vcMap = self.storyboard?.instantiateViewControllerWithIdentifier("Maps") as! MapViewController
                self.vcFriends = self.storyboard?.instantiateViewControllerWithIdentifier("Friends") as! FriendsActivity
            
                //Instantiate the frame sizes so they fit in main activity (need to figure out how to autosize them into a subview UIView or UIViewcontroller)
                self.vcMe.view.frame = CGRectMake(0, 0, vcMe.view.frame.width, vcMe.view.frame.size.height)
                self.vcMap.view.frame = CGRectMake(0, 0, vcMap.view.frame.width, vcMap.view.frame.size.height)
                self.vcFriends.view.frame = CGRectMake(0,0, vcFriends.view.frame.width, vcFriends.view.frame.size.height)
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let showname:String = prefs.stringForKey("SHOWNAME")!
                delegate.letsGetDatSocketRollin(username, showname1: showname)
                if (delegate.yourFriends.count == 0){
                    print("remember that you get the friend list in VIEWCONTENTCONTROLLER")
                    
                    delegate.queryFriends(username)
                    
                }
                
               // delegate.mSocket.emit("joinserver", username)

                
            }
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        override func viewDidAppear(animated: Bool) {
            super.viewDidAppear(true)
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
            if (isLoggedIn != 1) {
                            print(isLoggedIn)
                self.performSegueWithIdentifier("goto_login", sender: self)
            }else{
                self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
                let startVC = self.viewControllerAtIndex(self.index)
                let viewControllers = NSArray(object: startVC)
                self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
                self.pageViewController.view.frame = CGRectMake(0, 85, self.view.frame.width, self.view.frame.size.height-85)
                self.addChildViewController(self.pageViewController)
                self.view.addSubview(self.pageViewController.view)
                self.pageViewController.didMoveToParentViewController(self)
            }
        }
        
        func viewControllerAtIndex(index: Int) -> UIViewController
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
        @IBAction func indexChanged(sender: UISegmentedControl) {
            switch segmentIndex.selectedSegmentIndex{
            case 0:
                let viewControllers = NSArray(object: self.vcMe)
                self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .Forward, animated: true, completion: nil)
                self.index = 0
            case 1:
                let viewControllers = NSArray(object: self.vcMap)
                self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .Forward, animated: true, completion: nil)
                self.index = 1
            case 2:
                let viewControllers = NSArray(object: self.vcFriends)
                self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .Forward, animated: true, completion: nil)
                self.index = 2
            default:
                break
            }
        }

        func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
        {
            return self.pageTitles.count
        }
        
        func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
        {
            return 0
        }
        
        
        //on Button for Notificaions
        @IBAction func onNotificationPress(sender: UIButton) {
            vcNotif = self.storyboard?.instantiateViewControllerWithIdentifier("rendezNotifications") as! RendezNotifications
            self.presentViewController(vcNotif, animated: true, completion: nil)
        }
        
        //on Button for Ranges
        @IBAction func onInRanges(sender: UIButton) {
            vcInRanges = self.storyboard?.instantiateViewControllerWithIdentifier("rendezInRange") as! rendezChatInRangeViewController
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            vcInRanges.rendezes = delegate.r_rendezstatus
            vcInRanges.statuses = delegate.r_status
            self.presentViewController(vcInRanges, animated: true, completion: nil)
            
        }
        
        
        
    }
    
