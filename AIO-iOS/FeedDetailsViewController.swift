//
//  FeedDetailsViewController.swift
//  AIO-iOS
//
//  Created by Paula Petcu on 9/6/16.
//  Copyright © 2016 monohelix. All rights reserved.
//

import UIKit

class FeedDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet var feedNameLabel: UILabel!
    
    var selectedFeed: String!
    
    var tableView:UITableView?
    var histItems = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        feedNameLabel.text = selectedFeed

    }

    
    override func viewWillAppear(animated: Bool) {
        
        updateTableView(UIScreen.mainScreen().bounds.height, w: UIScreen.mainScreen().bounds.width)
        
        self.histItems.removeAllObjects();
        RestApiManager.sharedInstance.getHistoricalData(selectedFeed) { (json: JSON) in
            let history: JSON = json
            for (_, subJson) in history {
                if let hist: AnyObject = subJson.object {
                    self.histItems.addObject(hist)
                    self.histItems.sortUsingDescriptors([NSSortDescriptor(key: "id", ascending: true)])
                    if (self.histItems.count != 0) {
                        dispatch_async(dispatch_get_main_queue(),{
                            self.tableView?.reloadData()
                        })
                    }
                }
            }
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        updateTableView(size.height,w: size.width)
    }
    
    func updateTableView(h: CGFloat, w: CGFloat) {
        
        if tableView != nil {
            self.tableView?.removeFromSuperview()
        }
        
        let frame:CGRect = CGRect(x: 0, y: 100, width: w, height: h-150)
        self.tableView = UITableView(frame: frame)
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.view.addSubview(self.tableView!)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.histItems.count;
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") //as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
        }
        
        let histItem:JSON =  JSON(self.histItems[indexPath.row])
        
        if let timestamp: AnyObject = histItem["created_at"].string {
            cell!.textLabel?.text = timestamp as? String
            
            if let val: AnyObject = histItem["value"].string {
                cell!.textLabel?.text = (cell!.textLabel?.text)! + (val as! String)
            }
            
        }
        return cell!
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
