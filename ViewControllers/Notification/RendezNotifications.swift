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
        let delegate = UIApplication.shared.delegate as! AppDelegate
        someRendez.removeAll()
        someChat.removeAll()
        someStatus.removeAll()
        
        someRendez.append(contentsOf: delegate.rendezstatus )
        someChat.append(contentsOf: delegate.chat)
        someStatus.append(contentsOf: delegate.status)
        self.list0 = self.storyboard?.instantiateViewController(withIdentifier: "notifList") as! RendezNotifList
        
        self.list1 = self.storyboard?.instantiateViewController(withIdentifier: "notifList") as! RendezNotifList
        
        self.list2 = self.storyboard?.instantiateViewController(withIdentifier: "notifList") as! RendezNotifList
        self.list0.listType = 0
        self.list1.listType = 1
        self.list2.listType = 2
        
        self.list0.someStatus.append(contentsOf: someStatus)
        self.list1.someRendez.append(contentsOf: someRendez)
        self.list2.someChat.append(contentsOf: someChat)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let recognizerL: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(RendezNotifications.swipeLeft(_:)))
        recognizerL.direction = .left
        let recognizerR: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(RendezNotifications.swipeRight(_:)))
        recognizerR.direction = .right
        
        statusflag = 1
        rendezflag = 0
        chatflag = 0
        statusB.isSelected = true
        
        self.view.addGestureRecognizer(recognizerL)
        self.view.addGestureRecognizer(recognizerR)
        
        let startVC = self.viewControllerAtIndex(self.index)
        let viewControllers = NSArray(object: startVC)
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
        self.pageViewController.view.frame = CGRect(x: 0, y: 105, width: self.view.frame.width, height: self.view.frame.size.height-85)
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParentViewController: self)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func viewControllerAtIndex(_ index: Int) -> UIViewController
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
    
    func swipeLeft(_ recognizer : UISwipeGestureRecognizer) {
        if(self.index != 2 ){
            print("swipeLeft")
            self.index += 1
            let viewControllers = NSArray(object: viewControllerAtIndex(self.index))
            self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .forward, animated: true, completion: nil)
            setButtons()
            
        }
        
    }
    
    func swipeRight(_ recognizer : UISwipeGestureRecognizer) {
        if(self.index != 0 ){
            print("swipeRight")
            self.index -= 1
            let viewControllers = NSArray(object: viewControllerAtIndex(self.index))
            self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .reverse, animated: true, completion: nil)
            setButtons()
        }
    }
    
    func setButtons(){
        if(self.index == 0){
            rendezflag = 0
            chatflag = 0
            rendezB.isSelected = false
            chatB.isSelected = false
            
            statusflag = 1
            statusB.isSelected = true
        }else if(self.index == 1){
            rendezflag = 1
            chatflag = 0
            rendezB.isSelected = true
            chatB.isSelected = false
            
            statusflag = 0
            statusB.isSelected = false
        }else{
            rendezflag = 0
            chatflag = 1
            rendezB.isSelected = false
            chatB.isSelected = true
            
            statusflag = 0
            statusB.isSelected = false
        }
    }
    
    @IBAction func onStatus(_ sender: UIButton) {
        if(self.index != 0){
            self.index = 0
            let viewControllers = NSArray(object: viewControllerAtIndex(self.index))
            self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .reverse, animated: true, completion: nil)
            setButtons()
        }
    }
    @IBAction func onRendez(_ sender: UIButton) {
        if(self.index != 1){
            
            
            if(self.index < 1){
                self.index = 1
                let viewControllers = NSArray(object: viewControllerAtIndex(self.index))
            self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .forward, animated: true, completion: nil)
            }else{
                self.index = 1
                let viewControllers = NSArray(object: viewControllerAtIndex(self.index))
                self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .reverse, animated: true, completion: nil)
            }
            
            setButtons()
        }
        
    }
    @IBAction func onChat(_ sender: UIButton) {
        if(self.index != 2){
             self.index = 2
            let viewControllers = NSArray(object: viewControllerAtIndex(self.index))
            self.pageViewController.setViewControllers(viewControllers as? [UIViewController],direction: .forward, animated: true, completion: nil)
            
           
            
            setButtons()
            
        }
    }
    
    @IBAction func onBackPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
