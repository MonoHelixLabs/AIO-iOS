//
//  FeedDetailsViewController.swift
//  AIO-iOS
//
//  Created by Paula Petcu on 9/6/16.
//  Copyright © 2016 monohelix. All rights reserved.
//

import UIKit
import Charts

class FeedDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var selectedFeed: String!
    var limit: String!
    
    var tableView:UITableView?
    var histItems = NSMutableArray()
    
    //var currvalue = ""
    
    @IBOutlet var lineChartView: LineChartView!
    
    @IBOutlet var feedDetailsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = selectedFeed
    
    }

    
    override func viewWillAppear(animated: Bool) {
        
        updateTableView(UIScreen.mainScreen().bounds.height, w: UIScreen.mainScreen().bounds.width)
        
        limit = "50" // default value
        refreshHistFeedData()
        
        
        //let imgPrefs = UserDefaultsManager.sharedInstance.getImagesPreferences()
        
        
        /*if let val = imgPrefs[self.title!] {
            currvalue =  getStringFromEmoji(val)
        }
        else {
            currvalue = getStringFromEmoji(imgPrefs["default"]!)
        }*/
        
    }
    
    
    func refreshHistFeedData() {
        self.histItems.removeAllObjects();
        RestApiManager.sharedInstance.getHistoricalData(selectedFeed, limit: limit) { (json: JSON) in
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
            self.updateChart()
        }
    }
    
    func updateChart() {
        
        //let dateFormatter = NSDateFormatter()
        //dateFormatter.dateFormat = "yyyy-MM-ddTHH:mm:ss.zzzZ" //ex: 2016-09-06T20:09:10.127Z
        
        var ys = [Double]()
        for histItem in self.histItems {
            ys.append(Double(histItem["value"] as! String)!)
            //let date = dateFormatter.dateFromString(histItem["created_at"] as! String)
            
        }
        let yse = ys.enumerate().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        
        let data = LineChartData()
        
        let ds1 = LineChartDataSet(values: yse, label: selectedFeed)
        ds1.colors = [UIColor(red: 81.0/255.0, green: 173.0/255.0, blue: 233.0/255.0, alpha: 1.0)]
        ds1.drawCirclesEnabled = false
        ds1.drawValuesEnabled = false
        ds1.drawFilledEnabled = true
        ds1.fillColor = UIColor(red: 81.0/255.0, green: 173.0/255.0, blue: 233.0/255.0, alpha: 1.0)
        ds1.mode = LineChartDataSet.Mode.CubicBezier;
        ds1.cubicIntensity = 0.2;
        
        data.addDataSet(ds1)
        
        self.lineChartView.data = data
        self.lineChartView.rightAxis.enabled = false
        self.lineChartView.legend.enabled = false
        self.lineChartView.leftAxis.drawGridLinesEnabled = false
        self.lineChartView.leftAxis.axisMaximum = ys.maxElement()! + 10/100*(ys.maxElement()!-ys.minElement()!)
        self.lineChartView.leftAxis.axisMinimum = ys.minElement()! - 10/100*(ys.maxElement()!-ys.minElement()!)
        self.lineChartView.xAxis.labelPosition = Charts.XAxis.LabelPosition.Bottom
        self.lineChartView.xAxis.drawAxisLineEnabled = false
        self.lineChartView.gridBackgroundColor = NSUIColor.whiteColor()
        self.lineChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
        self.lineChartView.descriptionText = ""
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        updateTableView(size.height,w: size.width)
    }
    
    func updateTableView(h: CGFloat, w: CGFloat) {
        
        if tableView != nil {
            self.tableView?.removeFromSuperview()
        }
        
        // Only show the table if in Portrait
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
        
            let frame:CGRect = CGRect(x: 0, y: 280, width: w, height: h-380)
            self.tableView = UITableView(frame: frame)
            self.tableView?.dataSource = self
            self.tableView?.delegate = self
            self.view.addSubview(self.tableView!)
        }
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

    @IBAction func onGranularityChange(sender: UISegmentedControl) {
        
        let selectedSegment = sender.selectedSegmentIndex
        
        if (selectedSegment == 0) {
            limit = "50"
        }
        else if (selectedSegment == 1) {
            limit = "100"
        }
        else if (selectedSegment == 2) {
            limit = "200"
        }
        else if (selectedSegment == 3) {
            limit = "500"
        }
        
        refreshHistFeedData()
    }
    
    /*func getStringFromEmoji(emoji: String) -> String {
        return String(Character(UnicodeScalar(Int(emoji,radix:16)!)))
    }
    
    @IBAction func onFeedEditClick(sender: UIBarButtonItem) {
        
        print(self.title)
        
        
        
        let alertController = UIAlertController(title: self.title, message: "Select feed emoji", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addTextFieldWithConfigurationHandler(addTextField)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func addTextField(textField: UITextField!){
        // add the text field and make the result global
        textField.placeholder = currvalue
    }
    
    
    func checkMaxLength(textField: UITextField!, maxLength: Int) {
        if (textField.text!.characters.count > maxLength) {
            textField.deleteBackward()
        }
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "editFeed" {
            
            // get a reference to the second view controller
            let editFeedViewController = segue.destinationViewController as! EditFeedViewController
            
            // set a variable in the second view controller with the data to pass
            editFeedViewController.selectedFeed = selectedFeed
        }
    }

}
