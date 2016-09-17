//
//  ViewController.swift
//  DataFeeds
//
//  Created by Paula Petcu on 9/3/16.
//  Copyright © 2016 monohelixlabs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    #if os(iOS)
        @IBOutlet var feedTableView: UIView!
    #else
        @IBOutlet var feedTableViewTV: UIView!
    #endif
    
    var tableView:UITableView?
    var items = NSMutableArray()
    
    #if os(iOS)
        var refreshControl: UIRefreshControl!
    #endif
    
    var selectedFeedName: String!
    var selectedFeedKey: String!
    
    let defaultEmoji = String(Character(UnicodeScalar(Int("26AA",radix:16)!)))
    let warningEmoji = String(Character(UnicodeScalar(Int("26a0",radix:16)!)))
    
    override func viewDidLoad() {
        
        NSUserDefaults.standardUserDefaults().synchronize()
                
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        #if os(iOS)
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        #else
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(50)]
        #endif
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        updateTableView((UIScreen.mainScreen().bounds.height), w: (UIScreen.mainScreen().bounds.width))
        
        refreshFeedData(self)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        updateTableView(size.height,w: size.width)
    }
    
    
    func updateTableView(h: CGFloat, w: CGFloat) {
    
        if tableView != nil {
            self.tableView?.removeFromSuperview()
            #if os(iOS)
                self.refreshControl.removeFromSuperview()
            #endif
        }
        
        let frame:CGRect = CGRect(x: 0, y: 0, width: w, height: h-20)
        self.tableView = UITableView(frame: frame)
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        #if os(iOS)
            self.feedTableView.addSubview(self.tableView!)
        #else
            self.feedTableViewTV.addSubview(self.tableView!)
        #endif
            
        #if os(iOS)
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: "refreshFeedData:", forControlEvents: UIControlEvents.ValueChanged)
            self.tableView?.addSubview(refreshControl)
        #endif
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
                            #if os(iOS)
                                self.refreshControl?.endRefreshing()
                            #endif
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
            
            cell!.accessoryType = .DisclosureIndicator
            
            if let feedkey: AnyObject = feed["key"].string {
                if let val = imgPrefs[feedkey as! String] {
                    cell!.imageView!.image = getImageFromText(val)
                }
                else {
                    cell!.imageView!.image = getImageFromText(defaultEmoji)
                }
            }
                
            cell!.textLabel?.text = (feedname as! String)
            
            if let feedvalue = feed["last_value"].string {
                cell!.textLabel?.text = (cell!.textLabel?.text)! + ": " + feedvalue
            }

        }
        else {
            cell!.imageView!.image = getImageFromText(warningEmoji)
            if let error: AnyObject = feed.string {
                cell!.textLabel?.text = "Connection problem: " + (error as! String)
            }
            else {
                cell!.textLabel?.text = "Connection problem."
            }
        }
        return cell!
    }
    
    func getImageFromText(val: String) -> UIImage {
        
        #if os(iOS)
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            label.text = val
        #else
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
            label.text = "\t" + val
        #endif
        
        label.font = UIFont(name: "Arial",size:30)
        return UIImage.imageWithLabel(label)
    
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
        let feed:JSON =  JSON(self.items[indexPath.row])
        
        if let feedname: AnyObject = feed["name"].string {
            selectedFeedName = feedname as! String
            
            if let feedkey: AnyObject = feed["key"].string {
                selectedFeedKey = feedkey as! String
            }
            
            performSegueWithIdentifier("tableCellDetails", sender: self)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "tableCellDetails" {
            
            // get a reference to the second view controller
            let feedDetailsViewController = segue.destinationViewController as! FeedDetailsViewController
            
            // set a variable in the second view controller with the data to pass
            feedDetailsViewController.selectedFeedName = selectedFeedName
            feedDetailsViewController.selectedFeedKey = selectedFeedKey
        }
    }
    
}

extension UIImage {
    class func imageWithLabel(label: UILabel) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
