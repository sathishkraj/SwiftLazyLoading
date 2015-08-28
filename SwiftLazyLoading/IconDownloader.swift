//
//  IconDownloader.swift
//  SwiftLazyLoading
//
// Copyright (c) 2015 Sathish Kumar
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

let kAppIconSize: CGFloat = 48.0

class IconDownloader: NSObject {
   
    var appRecord: AppRecord? = nil
    var completionHandler: (() -> ())? = nil
    var activeDownload: NSMutableData? = nil
    var imageConnection: NSURLConnection? = nil
    
    func startDownload() {
        self.activeDownload = NSMutableData()
        
        let request: NSURLRequest = NSURLRequest(URL: NSURL(string: self.appRecord!.imageURLString! as String)!)
        
        let conn: NSURLConnection = NSURLConnection(request: request, delegate: self)!
        
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
        
        let image: UIImage = UIImage(data: self.activeDownload!)!
        
        if image.size.width != kAppIconSize || image.size.width != kAppIconSize {
            
            let itemSize: CGSize = CGSizeMake(kAppIconSize, kAppIconSize)
            
            UIGraphicsBeginImageContext(itemSize)
            let imageRect: CGRect = CGRectMake(0, 0, kAppIconSize, kAppIconSize)
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
