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
    
    let defaultEmoji = String(Character(UnicodeScalar(Int("26AA",radix:16)!)!))
    let warningEmoji = String(Character(UnicodeScalar(Int("26a0",radix:16)!)!))
    
    var iCloudKeyStore: NSUbiquitousKeyValueStore? = NSUbiquitousKeyValueStore()
    
    var timer: Timer!
        
    override func viewDidLoad() {
        
        
        UserDefaultsManager.sharedInstance.syncWithiCloud()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        #if os(iOS)
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        #else
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor(), NSFontAttributeName: UIFont.systemFontOfSize(50)]
        #endif
        
        if UserDefaultsManager.sharedInstance.getShownKeyScreen() == false && UserDefaultsManager.sharedInstance.getAIOkey() == "" {
            self.tabBarController!.selectedIndex = 1
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.ubiquitousKeyValueStoreDidChangeExternally),
                                                         name:  NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                                         object: iCloudKeyStore)
    }
    
    func ubiquitousKeyValueStoreDidChangeExternally() {
        UserDefaultsManager.sharedInstance.syncWithiCloud()
        
        if UserDefaultsManager.sharedInstance.getShownKeyScreen() == true {
            updateTableView((UIScreen.main.bounds.height), w: (UIScreen.main.bounds.width))
            refreshFeedData(self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        updateTableView((UIScreen.main.bounds.height), w: (UIScreen.main.bounds.width))
        refreshFeedData(self)
        
        if timer != nil {
            timer.invalidate()
        }
        let refreshInterval = UserDefaultsManager.sharedInstance.getRefreshRateMainFeedToInterval()
        if refreshInterval > 0 {
            timer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(ViewController.refreshFeedData(_:)), userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        updateTableView(size.height,w: size.width)
    }
    
    
    func updateTableView(_ h: CGFloat, w: CGFloat) {
    
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
            refreshControl.addTarget(self, action: #selector(ViewController.refreshFeedData(_:)), for: UIControlEvents.valueChanged)
            self.tableView?.addSubview(refreshControl)
        #endif
    }
    
    func refreshFeedData(_ sender:AnyObject) {
        
        var refreshInProgress = false
        
        if (!refreshInProgress)
        {
            refreshInProgress = true
            self.items.removeAllObjects();
            RestApiManager.sharedInstance.getLatestData { (json: JSON) in
                let feeds: JSON = json
                if feeds.count > 0 {
                    for (_, subJson) in feeds {
                        if let feed: AnyObject = subJson.object as AnyObject {
                            self.items.add(feed)
                            self.items.sort(using: [NSSortDescriptor(key: "name", ascending: true)])
                            if (self.items.count != 0) {
                                DispatchQueue.main.async {
                                    self.tableView?.reloadData()
                                    #if os(iOS)
                                        self.refreshControl?.endRefreshing()
                                    #endif
                                    refreshInProgress = false
                                }
                            }
                        }
                    }
                }
                else {
                    let alertController = UIAlertController(title: "Got not answer back from Adafruit.IO", message: "Please check your internet connection.", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    #if os(iOS)
                        self.refreshControl?.endRefreshing()
                    #endif
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CELL") //as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "CELL")
        }
        
        if indexPath.row < self.items.count {
            
            let feed:JSON =  JSON(self.items[indexPath.row])
            
            let imgPrefs = UserDefaultsManager.sharedInstance.getImagesPreferences()
            
            if let feedname: AnyObject = feed["name"].string as AnyObject {
                
                cell!.accessoryType = .disclosureIndicator
                
                if let feedkey: AnyObject = feed["key"].string as AnyObject {
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
                if let error: AnyObject = feed.string as AnyObject {
                    cell!.textLabel?.text = "Connection problem: " + (error as! String)
                }
                else {
                    cell!.textLabel?.text = "Connection problem."
                }
            }
        }
        return cell!
    }
    
    func getImageFromText(_ val: String) -> UIImage {
        
        #if os(iOS)
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            label.text = val
            label.font = UIFont(name: "Arial",size:30)
        #else
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 36))
            label.text = "\t" + val
            label.adjustsFontSizeToFitWidth = true
        #endif
        
        
        return UIImage.imageWithLabel(label)
    
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    
        let feed:JSON =  JSON(self.items[indexPath.row])
        
        if let feedname: AnyObject = feed["name"].string as AnyObject {
            selectedFeedName = feedname as! String
            
            if let feedkey: AnyObject = feed["key"].string as AnyObject {
                selectedFeedKey = feedkey as! String
            }
            
            performSegue(withIdentifier: "tableCellDetails", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "tableCellDetails" {
            
            // get a reference to the second view controller
            let feedDetailsViewController = segue.destination as! FeedDetailsViewController
            
            // set a variable in the second view controller with the data to pass
            feedDetailsViewController.selectedFeedName = selectedFeedName
            feedDetailsViewController.selectedFeedKey = selectedFeedKey
        }
    }
    
}

extension UIImage {
    class func imageWithLabel(_ label: UILabel) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
