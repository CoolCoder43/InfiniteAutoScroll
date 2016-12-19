//
//  ViewController.swift
//  Test
//
//  Created by Vicky on 12/16/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var scr: DDAutoInfiniteScroll!
    // CONFIRM DDScrollDataSource DDplaceHolderImage IMAGE
    var DDplaceHolderImage: UIImage?
    
    //TODO: - INITIALIZE YOUR IMAGE URL ARRAY HERE
    let imageArr  =  [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpDDInfiniteScroll()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    //MARK: SETTING UP DDINFINITE SCROLL
    
    func setUpDDInfiniteScroll(){
        // INITIALIZE DDScrollDataSource DDplaceHolderImage IMAGE

        DDplaceHolderImage = UIImage(named: "Background.png")
        self.scr.configScroll()
    }
    
           
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension ViewController : DDScrollDataSource {
    func DDnumberOfHorizontalScrollSegments() -> NSInteger {
        return imageArr.count
    }
    func DDimageURLForSegmentAtIndex(index: NSInteger) -> String {
        return imageArr[index]
    }
}





