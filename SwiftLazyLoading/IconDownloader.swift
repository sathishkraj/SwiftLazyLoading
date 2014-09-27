//
//  IconDownloader.swift
//  SwiftLazyLoading
//
//  Created by Sathish Kumar on 26/09/14.
//  Copyright (c) 2014 Sathish Kumar. All rights reserved.
//

import UIKit

let kAppIconSize: CGFloat = 48.0

class IconDownloader: NSObject {
   
    var appRecord: AppRecord? = nil
    var completionHandler: (() -> ())? = nil
    var activeDownload: NSMutableData? = nil
    var imageConnection: NSURLConnection? = nil
    
    func startDownload() {
        self.activeDownload = NSMutableData.data()
        
        var request: NSURLRequest = NSURLRequest(URL: NSURL(string: self.appRecord!.imageURLString!))
        
        var conn: NSURLConnection = NSURLConnection(request: request, delegate: self)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        self.imageConnection = conn;
    }
    
    func cancelDownload() {
        self.imageConnection?.cancel()
        self.imageConnection = nil
        self.activeDownload = nil
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.activeDownload?.appendData(data)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.activeDownload = nil
        self.imageConnection = nil
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        var image: UIImage = UIImage(data: self.activeDownload!)
        
        if image.size.width != kAppIconSize || image.size.width != kAppIconSize {
            
            var itemSize: CGSize = CGSizeMake(kAppIconSize, kAppIconSize)
            
            UIGraphicsBeginImageContext(itemSize)
            var imageRect: CGRect = CGRectMake(0, 0, kAppIconSize, kAppIconSize)
            image.drawInRect(imageRect)
            self.appRecord!.appIcon = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        } else {
            self.appRecord!.appIcon = image
        }
        
        self.activeDownload = nil
        self.imageConnection = nil
        
        if self.completionHandler != nil {
            self.completionHandler!()
        }
        
    }
    
}
