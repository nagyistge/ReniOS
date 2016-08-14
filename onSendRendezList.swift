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
    
    var rendez: [Status]!
    var friends: [Friend]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collection1.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.collection2.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            
            return model[collectionView.tag].count
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell",
                forIndexPath: indexPath)
            
            cell.backgroundColor = model[collectionView.tag][indexPath.item]
            
            return cell
    }


}
