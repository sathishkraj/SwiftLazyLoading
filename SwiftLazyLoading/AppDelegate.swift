//
//  AppDelegate.swift
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

let TopPaidAppsFeed: NSString = "http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=75/xml"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //variables
    var queue: NSOperationQueue? = nil
    // RSS feed network connection to the App Store
    var appListFeedConnection: NSURLConnection? = nil
    var appListData: NSMutableData? = nil


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let url: NSURL = NSURL(string: TopPaidAppsFeed as String)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        self.appListFeedConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)
        
        assert(self.appListFeedConnection != nil, "Failure to create URL connection.")
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        return true
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        self.appListData = NSMutableData()
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.appListData?.appendData(data)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        //check the error code
        self.handleError(error)
        self.appListFeedConnection = nil
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        
        self.appListFeedConnection = nil
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        self.queue = NSOperationQueue()
        
        let parser: ParseOperation = ParseOperation(data: self.appListData)
        
        parser.errorHandler = { (error: NSError?) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.handleError(error!)
            })
        }
        
        
        parser.completionBlock = {
            if var _: NSArray = parser.appRecordList {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let navigationController: UINavigationController = self.window?.rootViewController as! UINavigationController
                    let rootViewController: ViewController = navigationController.topViewController as! ViewController
                    
                    rootViewController.entries = parser.appRecordList
                    rootViewController.tableView.reloadData()
                })
            }
            
            self.queue = nil;
        }
        
        self.queue?.addOperation(parser)
        
        self.appListData = nil
        
    }

    func handleError(error: NSError) {
        
        let errorMessage: NSString = error.localizedDescription
        
        let alert: UIAlertView = UIAlertView(title: "Cannot show top paid apps", message: errorMessage as String, delegate: nil, cancelButtonTitle: "Ok")
        
        alert.show()

    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

