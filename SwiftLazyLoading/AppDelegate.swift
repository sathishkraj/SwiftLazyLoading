//
//  AppDelegate.swift
//  SwiftLazyLoading
//
//  Created by Sathish Kumar on 24/09/14.
//  Copyright (c) 2014 Sathish Kumar. All rights reserved.
//

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
        
        var url: NSURL = NSURL.URLWithString(TopPaidAppsFeed)
        var request: NSURLRequest = NSURLRequest(URL: url)
        self.appListFeedConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)
        
        assert(self.appListFeedConnection != nil, "Failure to create URL connection.")
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        return true
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        self.appListData = NSMutableData.data()
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
        
        var parser: ParseOperation = ParseOperation(data: self.appListData)
        
        parser.errorHandler = { (error: NSError?) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.handleError(error!)
            })
        }
        
        weak var weakParser: ParseOperation? = parser
        
        parser.completionBlock = {
            if var appRecord: NSArray = parser.appRecordList {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var navigationController: UINavigationController = self.window?.rootViewController as UINavigationController
                    var rootViewController: ViewController = navigationController.topViewController as ViewController
                    
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
        
        var errorMessage: NSString = error.localizedDescription
        
        var alert: UIAlertView = UIAlertView(title: "Cannot show top paid apps", message: errorMessage, delegate: nil, cancelButtonTitle: "Ok")
        
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

