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
    var imageDownloadsInProgress: NSMutableDictionary? = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.handleError(NSError(domain: "Hello", code: 400, userInfo: nil))
        
        self.imageDownloadsInProgress = NSMutableDictionary()
    }
    
    func handleError(error: NSError) {
        
        let errorMessage: NSString = error.localizedDescription
        let alert: UIAlertController = UIAlertController(title: "Cannot show top paid apps", message:errorMessage as String, preferredStyle:UIAlertControllerStyle.Alert)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (action: UIAlertAction) -> Void in
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
        
        let nodeCount: NSInteger = self.entries!.count
        
        var cell : UITableViewCell
        
        if nodeCount == 0 && indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier as String)!
            cell.textLabel?.text = "Loading..."
            return cell
        }
        
        cell = tableView.dequeueReusableCellWithIdentifier(PlaceholderCellIdentifier as String)!
        
        let appRecord: AppRecord = self.entries!.objectAtIndex(indexPath.row) as! AppRecord
        
        cell.textLabel?.text = appRecord.appName as? String
        cell.detailTextLabel?.text = appRecord.artist as? String
        
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
        if let _ = self.imageDownloadsInProgress!.objectForKey(indexPath) as? IconDownloader {
            
        } else {
            let iconDownloader: IconDownloader = IconDownloader()
            iconDownloader.appRecord = appRecord
            
            iconDownloader.completionHandler = {
                let cell: UITableViewCell? = self.tableView.cellForRowAtIndexPath(indexPath)
                
                if let image = appRecord!.appIcon {
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
            let visiblePaths: NSArray = self.tableView.indexPathsForVisibleRows!
            for var index = 0; index < visiblePaths.count; index++  {
                let indexPath: NSIndexPath = visiblePaths.objectAtIndex(index) as! NSIndexPath
                let appRecord: AppRecord = self.entries?.objectAtIndex(indexPath.row) as! AppRecord
                    
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
        
        let allDownloads: NSArray = self.imageDownloadsInProgress!.allValues
        
        //var downloader: IconDownloader
        for var index = 0; index < allDownloads.count; index++ {
            let downloader: IconDownloader = allDownloads.objectAtIndex(index) as! IconDownloader
            downloader.cancelDownload()
         }
        
        self.imageDownloadsInProgress?.removeAllObjects()
    }


}

