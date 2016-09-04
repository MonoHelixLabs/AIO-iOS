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
        
    // TO-DO: manage storage of images and the ability to add new images
    
    // TO-DO: get historical data when clicking on one of the feeds (i.e. do the request for getting the historical data); also have option to view data for last hour, last 24 hours, or last month
    
    // TO-DO: scenes combining different sensors (for example a heatmap of temperatures)
    
    override func viewDidLoad() {
        
        NSUserDefaults.standardUserDefaults().synchronize()
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
        
        if let feedname: AnyObject = feed["name"].string {
                    
            if feed["description"].string == "temperature" {
                cell!.textLabel?.text = String(Character(UnicodeScalar(Int("1f321",radix:16)!)))
            }
            else if feed["description"].string == "scale" {
                cell!.textLabel?.text = String(Character(UnicodeScalar(Int("1f37c",radix:16)!)))
            }
            else if feed["description"].string == "humidity" {
                cell!.textLabel?.text = String(Character(UnicodeScalar(Int("1f4a7",radix:16)!)))
            }
            else {
                cell!.textLabel?.text = " "
            }
            
            cell!.textLabel?.text = (cell!.textLabel?.text)! + " " + (feedname as! String) + ": " + feed["last_value"].string!

        }
        else {
            cell!.textLabel?.text = String(Character(UnicodeScalar(Int("26a0",radix:16)!)))
            if let error: AnyObject = feed.string {
                cell!.textLabel?.text = (cell!.textLabel?.text)! + "Connection problem: " + (error as! String)
            }
            else {
                cell!.textLabel?.text = (cell!.textLabel?.text)! + "Connection problem."
            }
        }
        return cell!
    }
    
    
}