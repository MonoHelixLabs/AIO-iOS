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
    
    var tableView:UITableView?
    var histItems = NSMutableArray()
    
    @IBOutlet var lineChartView: LineChartView!
    
    @IBOutlet var feedDetailsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = selectedFeed
    
        //let data = LineChartData()
        
        /*let ds1 = LineChartDataSet(values: [1,1,0,1,900,450,1,1,0], label: selectedFeed)
        ds1.colors = [NSUIColor.blueColor()]
        data.addDataSet(ds1)
        self.lineChartView.data = data
        self.lineChartView.gridBackgroundColor = NSUIColor.whiteColor()*/
        
        
        // Do any additional setup after loading the view.
        /*let ys1 = Array(1..<10).map { x in return sin(Double(x) / 2.0 / 3.141 * 1.5) }
        let ys2 = Array(1..<10).map { x in return cos(Double(x) / 2.0 / 3.141) }
        
        let yse1 = ys1.enumerate().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        let yse2 = ys2.enumerate().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        
        let data = LineChartData()
        let ds1 = LineChartDataSet(values: yse1, label: "Hello")
        ds1.colors = [NSUIColor.redColor()]
        data.addDataSet(ds1)
        
        let ds2 = LineChartDataSet(values: yse2, label: "World")
        ds2.colors = [NSUIColor.blueColor()]
        data.addDataSet(ds2)
        self.lineChartView.data = data
        
        self.lineChartView.gridBackgroundColor = NSUIColor.whiteColor()
        
        self.lineChartView.descriptionText = "Linechart Demo"*/
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
            self.updateChart()
        }
        
        
    }
    
    func updateChart() {
        
        var ys = [Double]()
        for histItem in self.histItems {
            ys.append(Double(histItem["value"] as! String)!)
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
        self.lineChartView.leftAxis.axisMaximum = ys.maxElement()! + 5/100*ys.maxElement()!
        self.lineChartView.leftAxis.axisMinimum = ys.minElement()! - 5/100*ys.minElement()!
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
        
        let frame:CGRect = CGRect(x: 0, y: 250, width: w, height: h-350)
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
