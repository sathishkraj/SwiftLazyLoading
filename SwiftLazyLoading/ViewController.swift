//
//  ViewController.swift
//  SwiftLazyLoading
//
//  Created by Sathish Kumar on 24/09/14.
//  Copyright (c) 2014 Sathish Kumar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var entries: NSArray? = nil
    var imageDownloadsInProgress: NSMutableDictionary? = NSMutableDictionary.dictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.handleError(NSError(domain: "Hello", code: 400, userInfo: nil))
        
        self.imageDownloadsInProgress = NSMutableDictionary.dictionary()
    }
    
    func handleError(error: NSError) {
        
        var errorMessage: NSString = error.localizedDescription
        var alert: UIAlertController = UIAlertController(title: "Cannot show top paid apps", message:errorMessage, preferredStyle:UIAlertControllerStyle.Alert)
        
        var okAction: UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
            alert.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        }
        
        alert.addAction(okAction)
        presentViewController(alert, animated: true) { () -> Void in
            
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.entries != nil {
            return self.entries!.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let CellIdentifier: NSString = "LazyTableCell"
        let PlaceholderCellIdentifier: NSString = "PlaceholderCell"
        
        var nodeCount: NSInteger = self.entries!.count
        
        var cell : UITableViewCell
        
        if nodeCount == 0 && indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as UITableViewCell
            cell.textLabel?.text = "Loading..."
            return cell
        }
        
        cell = tableView.dequeueReusableCellWithIdentifier(PlaceholderCellIdentifier) as UITableViewCell
        
        var appRecord: AppRecord = self.entries!.objectAtIndex(indexPath.row) as AppRecord
        
        cell.textLabel?.text = appRecord.appName
        cell.detailTextLabel?.text = appRecord.artist
        
        if appRecord.appIcon == nil {
            if self.tableView.dragging == false && self.tableView.decelerating == false {
                //[self startIconDownload:appRecord forIndexPath:indexPath];
                self.startIconDownload(appRecord, indexPath: indexPath)
            }
            cell.imageView?.image = UIImage(named: "Placeholder.png")
        } else {
            cell.imageView?.image = appRecord.appIcon
        }
        
        return cell
        
    }
    
    func startIconDownload(appRecord: AppRecord?, indexPath: NSIndexPath) {
        //var iconDownloader: IconDownloader? = nil
        //iconDownloader = (self.imageDownloadsInProgress!.objectForKey(indexPath) as IconDownloader)
        if var iconDownloader = self.imageDownloadsInProgress!.objectForKey(indexPath) as? IconDownloader {
            
        } else {
            var iconDownloader: IconDownloader = IconDownloader()
            iconDownloader.appRecord = appRecord
            
            iconDownloader.completionHandler = {
                var cell: UITableViewCell? = self.tableView.cellForRowAtIndexPath(indexPath)
                
                if var image = appRecord!.appIcon {
                    cell!.imageView!.image = image
                } else {
                    
                }
                
                self.imageDownloadsInProgress!.removeObjectForKey(indexPath)
            }
            
            self.imageDownloadsInProgress!.setObject(iconDownloader, forKey: indexPath)
            iconDownloader.startDownload()
        }
    }
    
    func loadImagesForOnscreenRows() {
        if self.entries?.count > 0 {
            var visiblePaths: NSArray = self.tableView.indexPathsForVisibleRows()!
            for var index = 0; index < visiblePaths.count; index++  {
                var indexPath: NSIndexPath = visiblePaths.objectAtIndex(index) as NSIndexPath
                var appRecord: AppRecord = self.entries?.objectAtIndex(indexPath.row) as AppRecord
                    
                    if appRecord.appIcon == nil {
                        self.startIconDownload(appRecord, indexPath: indexPath)
                    }
                }
            }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.loadImagesForOnscreenRows()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.loadImagesForOnscreenRows()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        var allDownloads: NSArray = self.imageDownloadsInProgress!.allValues
        
        //var downloader: IconDownloader
        for var index = 0; index < allDownloads.count; index++ {
            var downloader: IconDownloader = allDownloads.objectAtIndex(index) as IconDownloader
            downloader.cancelDownload()
         }
        
        self.imageDownloadsInProgress?.removeAllObjects()
    }


}

