//
//  RendezNotifications.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 7/29/16.
//  Copyright © 2016 John Jin Woong Kim. All rights reserved.
//

import UIKit

class RendezNotifications: UIViewController {

    /*
        Bout time I got around to making a listview for notifications... now that there are
        actual features that can ALLOW for notifications to even happen.
    
        heh.
        *cries
    */
    var someRendez = [RendezStatus]()
    var someChat = [Chat]()
    var someStatus = [Status]()
    
    @IBOutlet weak var statusB: UIButton!
    @IBOutlet weak var rendezB: UIButton!
    @IBOutlet weak var chatB: UIButton!
    
    var statusflag:Int!
    var rendezflag:Int!
    var chatflag:Int!
    
    var pageViewController: UIPageViewController!
    var pageTitles: NSArray = ["Status","Rendez", "Messages"]
    var list0: RendezNotifList!//status vc
    var list1: RendezNotifList!//rendez vc
    var list2: RendezNotifList!//message vc
    var index:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
                // Do any additional setup after loading the view.
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        someRendez.removeAll()
        someChat.removeAll()
        someStatus.removeAll()
        
        someRendez.appendContentsOf(delegate.rendezstatus )
        someChat.appendContentsOf(delegate.chat)
        someStatus.appendContentsOf(delegate.status)
        self.list0 = self.storyboard?.instantiateViewControllerWithIdentifier("notifList") as! RendezNotifList
        
        self.list1 = self.storyboard?.instantiateViewControllerWithIdentifier("notifList") as! RendezNotifList
        
        self.list2 = self.storyboard?.instantiateViewControllerWithIdentifier("notifList") as! RendezNotifList
        self.list0.listType = 0
        self.list1.listType = 1
        self.list2.listType = 2
        
        self.list0.someStatus.appendContentsOf(someStatus)
        self.list1.someRendez.appendContentsOf(someRendez)
        self.list2.someChat.appendContentsOf(someChat)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let recognizerL: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeft:")
        recognizerL.direction = .Left
        let recognizerR: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRight:")
        recognizerR.direction = .Right
        
        statusflag = 1
        rendezflag = 0
        chatflag = 0
        statusB.selected = true
        
        self.view.addGestureRecognizer(recognizerL)
        self.view.addGestureRecognizer(recognizerR)
        
        let startVC = self.viewControllerAtIndex(self.index)
        let viewControllers = NSArray(object: startVC)
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
        self.pageViewController.view.frame = CGRectMake(0, 150, self.view.frame.width, self.view.frame.size.height-85)
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func viewControllerAtIndex(index: Int) -> UIViewController
    {
        if ((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
            return ContentViewController()
        }
        var vc: UIViewController
        if(index == 0){
            vc = self.list0
        }
        else if(index == 1){
            vc = self.list1
        }
        else{
            vc = self.list2
        }
        return vc
    }
    
    func swipeLeft(recognizer : UISwipeGestureRecognizer) {
        if(self.index != 2 ){
            print("swipeLeft")
            self.index += 1
            let viewControllers = NSArray(object: viewControllerAtIndex(self.index))
            self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .Forward, animated: true, completion: nil)
            setButtons()
            
        }
        
    }
    
    func swipeRight(recognizer : UISwipeGestureRecognizer) {
        if(self.index != 0 ){
            print("swipeRight")
            self.index -= 1
            let viewControllers = NSArray(object: viewControllerAtIndex(self.index))
            self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .Reverse, animated: true, completion: nil)
            setButtons()
        }
    }
    
    func setButtons(){
        if(self.index == 0){
            rendezflag = 0
            chatflag = 0
            rendezB.selected = false
            chatB.selected = false
            
            statusflag = 1
            statusB.selected = true
        }else if(self.index == 1){
            rendezflag = 1
            chatflag = 0
            rendezB.selected = true
            chatB.selected = false
            
            statusflag = 0
            statusB.selected = false
        }else{
            rendezflag = 0
            chatflag = 1
            rendezB.selected = false
            chatB.selected = true
            
            statusflag = 0
            statusB.selected = false
        }
    }
    
    @IBAction func onStatus(sender: UIButton) {
        if(self.index != 0){
            self.index = 0
            let viewControllers = NSArray(object: viewControllerAtIndex(self.index))
            self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .Reverse, animated: true, completion: nil)
            setButtons()
        }
    }
    @IBAction func onRendez(sender: UIButton) {
        if(self.index != 1){
            
            
            if(self.index < 1){
                self.index = 1
                let viewControllers = NSArray(object: viewControllerAtIndex(self.index))
            self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .Forward, animated: true, completion: nil)
            }else{
                self.index = 1
                let viewControllers = NSArray(object: viewControllerAtIndex(self.index))
                self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .Reverse, animated: true, completion: nil)
            }
            
            setButtons()
        }
        
    }
    @IBAction func onChat(sender: UIButton) {
        if(self.index != 2){
             self.index = 2
            let viewControllers = NSArray(object: viewControllerAtIndex(self.index))
            self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .Forward, animated: true, completion: nil)
            
           
            
            setButtons()
            
        }
    }
    
    @IBAction func onBackPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

  

}
