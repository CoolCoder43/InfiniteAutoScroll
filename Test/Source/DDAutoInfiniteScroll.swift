//
//  DDAutoInfiniteselfoll.swift
//  Test
//
//  Created by Vicky on 12/18/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

import UIKit
protocol DDScrollDataSource{
    func DDnumberOfHorizontalScrollSegments()->NSInteger
    func DDimageURLForSegmentAtIndex(index:NSInteger)-> String
    var  DDplaceHolderImage :UIImage? { get set}
}

class DDAutoInfiniteScroll : UIScrollView {
    @IBOutlet weak var DDpageControl: UIPageControl?
    @IBOutlet weak var DDdataSource: AnyObject? {
        get { return self.dataSource as AnyObject }
        set { dataSource = newValue as? DDScrollDataSource }
    }
    var dataSource : DDScrollDataSource!
    var count = 0
    var imageCount = 0
    let screen = UIScreen.main

    private struct DDScrollConstants {
        static let TOTAL_SEGMENTS_REUSED = 2 //SHOULD NEVER BE CHANGED
        static let FIRST_IMAGEVIEW_TAG = 121
        static let SECOND_IMAGEVIEW_TAG = 131
        static let DISPATCH_TIME = 3
        static var HEIGHT = 230.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        for constraint in self.constraints {
            if constraint.firstAttribute == .height{
                DDScrollConstants.HEIGHT = Double(constraint.constant)
                break
            }
        }
    }
    
    func configScroll(){
        if let source = self.dataSource {
            self.imageCount = source.DDnumberOfHorizontalScrollSegments()
        }else { print("DataSorce Missing..")}
        if self.imageCount <= 0 {
            return
        }
        self.contentSize.width = CGFloat(DDScrollConstants.TOTAL_SEGMENTS_REUSED) * screen.bounds.width
        self.isPagingEnabled = true
        let imgVw1 = UIImageView(frame: CGRect.init(x: 0, y: 0, width: Int(screen.bounds.width), height: Int(DDScrollConstants.HEIGHT)))
        imgVw1.tag = DDScrollConstants.FIRST_IMAGEVIEW_TAG
        self.addSubview(imgVw1)
        let imgVw2 =  UIImageView(frame: CGRect.init(x: Int(screen.bounds.width), y: 0, width: Int(screen.bounds.width), height: Int(DDScrollConstants.HEIGHT)))
        imgVw2.tag = DDScrollConstants.SECOND_IMAGEVIEW_TAG
        self.addSubview(imgVw2)
        if let pageControl = DDpageControl{
            pageControl.numberOfPages = imageCount
        }
        (self.viewWithTag(DDScrollConstants.FIRST_IMAGEVIEW_TAG) as! UIImageView).image = getImageForURL(url: dataSource.DDimageURLForSegmentAtIndex(index: count), tags: DDScrollConstants.FIRST_IMAGEVIEW_TAG)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(DDScrollConstants.DISPATCH_TIME), execute: {
            self.letTheGameBegin()
        })
    }
    
    
    private func  letTheGameBegin(){
        if self.contentOffset.x == 0{
            count = count + 1
            if let pageControl = DDpageControl{
                pageControl.currentPage = count
            }
            (self.viewWithTag(DDScrollConstants.SECOND_IMAGEVIEW_TAG) as! UIImageView).image = getImageForURL(url: dataSource.DDimageURLForSegmentAtIndex(index: count), tags: DDScrollConstants.SECOND_IMAGEVIEW_TAG)
            self.setContentOffset(CGPoint.init(x: self.contentOffset.x + screen.bounds.width, y: 0), animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(DDScrollConstants.DISPATCH_TIME), execute: {
                self.letTheGameBegin()
            })
        }else{
            self.setContentOffset(CGPoint.init(x: 0, y: 0), animated: false)
            (self.viewWithTag(DDScrollConstants.FIRST_IMAGEVIEW_TAG) as! UIImageView).image = getImageForURL(url: dataSource.DDimageURLForSegmentAtIndex(index: count), tags: DDScrollConstants.FIRST_IMAGEVIEW_TAG)
            if count == imageCount - 1 {
                count = -1
            }
            self.letTheGameBegin()
        }
    }
    
   private func getImageForURL(url:String, tags : Int)->UIImage? {
        if let img = getImageAtPath(url: url as NSString){
            return img
        }else{
            (self.viewWithTag(tags) as! UIImageView).downloadImage(url: url as String)
        }
        return dataSource.DDplaceHolderImage
    }
    
    
   private func getImageAtPath(url : NSString) -> UIImage? {
        let directoryPath  =   try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let urlString : URL       =  directoryPath.appendingPathComponent(url.components(separatedBy: "/").last!)
        if FileManager.default.fileExists(atPath: urlString.path) {
            return UIImage(contentsOfFile: urlString.path)
        }
        return nil
    }
    

    
}

 extension UIImageView
{
    func getDataFromUrl(url:String, completion: @escaping ((Data?, URLResponse?) -> Void)) {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            completion(data, response)
            }.resume()
    }
    
    func downloadImage(url:String){
        getDataFromUrl(url: url) { (data, response) in
            DispatchQueue.main.async {
                if let imageData = data{
                    if url == response?.url?.absoluteString{
                        self.image = UIImage(data: imageData as Data)
                    }
                    self.saveImageToDirectory(url: url, data: imageData)
                }
            }
        }
    }
    
    func saveImageToDirectory(url :String , data: Data){
        let directoryPath  =  try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let urlString : URL       =  directoryPath.appendingPathComponent(url.components(separatedBy: "/").last!)
        if !FileManager.default.fileExists(atPath: urlString.path) {
            do {
               try data.write(to: urlString , options: .withoutOverwriting)
            }catch {}
        }
    }
    
}


