//
//  ViewController.swift
//  AIO-iOS
//
//  Created by Paula Petcu on 9/3/16.
//  Copyright © 2016 monohelix. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView:UITableView?
    var items = NSMutableArray()
    
    var refreshControl: UIRefreshControl!
    
    var selectedFeed: String!
    
    var imgPrefs:[String:String] = ["temperature":"1f321", "humidity":"1f4a7", "scale":"1f37c", "default":"26AA"]
    
    // TO-DO: manage storage of images and the ability to add new images
    
    // TO-DO: get historical data when clicking on one of the feeds (i.e. do the request for getting the historical data); also have option to view data for last hour, last 24 hours, or last month
    
    // TO-DO: scenes combining different sensors (for example a heatmap of temperatures)
    
    override func viewDidLoad() {
        
        //NSUserDefaults.standardUserDefaults().synchronize()
        
        UserDefaultsManager.sharedInstance.setImagesPreferences(imgPrefs)
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        updateTableView(UIScreen.mainScreen().bounds.height, w: UIScreen.mainScreen().bounds.width)
        
        refreshFeedData(self)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        updateTableView(size.height,w: size.width)
    }
    
    
    func updateTableView(h: CGFloat, w: CGFloat) {
    
        if tableView != nil {
            self.tableView?.removeFromSuperview()
            self.refreshControl.removeFromSuperview()
        }
        
        let frame:CGRect = CGRect(x: 0, y: 75, width: w, height: h-150)
        self.tableView = UITableView(frame: frame)
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.view.addSubview(self.tableView!)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshFeedData:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView?.addSubview(refreshControl)
    }
    
    func refreshFeedData(sender:AnyObject) {
        self.items.removeAllObjects();
        RestApiManager.sharedInstance.getLatestData { (json: JSON) in
            let feeds: JSON = json
            for (_, subJson) in feeds {
                if let feed: AnyObject = subJson.object {
                    self.items.addObject(feed)
                    self.items.sortUsingDescriptors([NSSortDescriptor(key: "name", ascending: true)])
                    if (self.items.count != 0) {
                        dispatch_async(dispatch_get_main_queue(),{
                            self.tableView?.reloadData()
                            self.refreshControl?.endRefreshing()
                        })
                    }
                }
            }
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") //as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
        }
        
        let feed:JSON =  JSON(self.items[indexPath.row])
        
        let imgPrefs = UserDefaultsManager.sharedInstance.getImagesPreferences()
        
        if let feedname: AnyObject = feed["name"].string {
            
            if let val = imgPrefs[feed["description"].string!] {
                cell!.textLabel?.text =  getStringFromEmoji(val)
            }
            else {
                cell!.textLabel?.text = getStringFromEmoji("26AA")
            }
            
            cell!.textLabel?.text = (cell!.textLabel?.text)! + " " + (feedname as! String) + ": " + feed["last_value"].string!

        }
        else {
            cell!.textLabel?.text = getStringFromEmoji("26a0") // warning
            if let error: AnyObject = feed.string {
                cell!.textLabel?.text = (cell!.textLabel?.text)! + "Connection problem: " + (error as! String)
            }
            else {
                cell!.textLabel?.text = (cell!.textLabel?.text)! + "Connection problem."
            }
        }
        return cell!
    }
    
    func getStringFromEmoji(emoji: String) -> String {
        return String(Character(UnicodeScalar(Int(emoji,radix:16)!)))
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
        let feed:JSON =  JSON(self.items[indexPath.row])
        
        if let feedname: AnyObject = feed["name"].string {
            selectedFeed = feedname as! String
            performSegueWithIdentifier("tableCellDetails", sender: self)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "tableCellDetails" {
            
            // get a reference to the second view controller
            let feedDetailsViewController = segue.destinationViewController as! FeedDetailsViewController
            
            // set a variable in the second view controller with the data to pass
            feedDetailsViewController.selectedFeed = selectedFeed
        }
    }
    
}