//
//  FeedDetailsViewController.swift
//  DataFeeds
//
//  Created by Paula Petcu on 9/6/16.
//  Copyright © 2016 monohelixlabs. All rights reserved.
//

import UIKit
import Charts

class FeedDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var selectedFeedName: String!
    var selectedFeedKey: String!
    var limit: String!
    
    var tableView:UITableView?
    var histItems = NSMutableArray()
    
    let dayTimePeriodFormatterIn = DateFormatter()
    let dayTimePeriodFormatterOut = DateFormatter()
    
    var timer: Timer!
    
    #if os(iOS)
        @IBOutlet var lineChartView: LineChartView!
    #else
        @IBOutlet var lineChartView: LineChartView!
    #endif
    
    #if os(iOS)
        @IBOutlet var feedDetailsView: UIView!
    #endif
    
    #if os(iOS)
        var refreshControl: UIRefreshControl!
    #endif
    
    #if os(iOS)
        @IBOutlet var feedDetailsStackView: UIStackView!
    #endif
    
    #if os(iOS)
        @IBOutlet var granularitySegmentedControl: UISegmentedControl!
    #endif
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.title = selectedFeedName
        #if os(iOS)
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        #else
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.black, NSFontAttributeName: UIFont.systemFont(ofSize: 50)]
        #endif
        
        dayTimePeriodFormatterIn.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dayTimePeriodFormatterOut.dateFormat = "MMM dd YYYY HH:mm:ss"

    }

    
    override func viewWillAppear(_ animated: Bool) {
               
        limit = "50" // default value
        #if os(iOS)
            granularitySegmentedControl.selectedSegmentIndex = 0
        #endif
        
        updateTableView(UIScreen.main.bounds.height, w: UIScreen.main.bounds.width)
        refreshHistFeedData(self)
        
        if timer != nil {
            timer.invalidate()
        }
        let refreshInterval = UserDefaultsManager.sharedInstance.getRefreshRateFeedDetailsToInterval()
        if refreshInterval > 0 {
            timer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(FeedDetailsViewController.refreshHistFeedData(_:)), userInfo: nil, repeats: true)
        }
        
    }
    
    
    func refreshHistFeedData(_ sender:AnyObject) {
        
        var refreshInProgress = false
        
        if (!refreshInProgress)
        {
            self.histItems.removeAllObjects();
            RestApiManager.sharedInstance.getHistoricalDataBasedOnLimit(selectedFeedKey, limit: limit) { (json: JSON) in
                let history: JSON = json
                for (_, subJson) in history {
                    if let hist: AnyObject = subJson.object as AnyObject {
                        self.histItems.add(hist)
                        self.histItems.sort(using: [NSSortDescriptor(key: "created_at", ascending: false)])
                        if (self.histItems.count != 0) {
                            DispatchQueue.main.async(execute: {
                                self.tableView?.reloadData()
                                #if os(iOS)
                                    self.refreshControl?.endRefreshing()
                                #endif
                                refreshInProgress = false
                            })
                        }
                        
                    }
                }
                self.updateChart()
            }
        }
    }
        
    func updateChart() {
        
        if self.histItems.count > 0 {
           
            if self.histItems.contains(where: {$0 is [String:Any]}) {
            
            var sortedHistItems = self.histItems.mutableCopy() as! NSMutableArray
            sortedHistItems.sort(using: [NSSortDescriptor(key: "created_at", ascending: true)])
            
            var xs = [Double]()
            var ys = [Double]()
            var yse = [ChartDataEntry]()

                for histItem in sortedHistItems as! [[String: Any]] {
                    if Double((histItem["value"] as? String)!) != nil {
                        let timestamp = dayTimePeriodFormatterIn.date(from: histItem["created_at"] as! String)?.timeIntervalSince1970
                        xs.append(timestamp!)
                        let x = timestamp!
                        ys.append(Double(histItem["value"] as! String)!)
                        let y = Double(histItem["value"] as! String)!
                        yse.append(ChartDataEntry(x: x,y: y))
                    }
                
            }
            
            if ys.count > 0 {
                let minElement = ys.min()!
                let maxElement = ys.max()!
                
                let data = LineChartData()
                
                let ds1 = LineChartDataSet(values: yse, label: selectedFeedName)
                ds1.colors = [UIColor(red: 0.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)]
                ds1.drawCirclesEnabled = false
                ds1.drawValuesEnabled = false
                ds1.drawFilledEnabled = true
                ds1.fillColor = UIColor(red: 0.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
                ds1.mode = LineChartDataSet.Mode.horizontalBezier//.stepped//.linear//.horizontalBezier
                //ds1.cubicIntensity = 0.2
                ds1.setDrawHighlightIndicators(false)
                
                data.addDataSet(ds1)
                
                self.lineChartView.data = data
                self.lineChartView.rightAxis.enabled = false
                self.lineChartView.legend.enabled = false
                
                self.lineChartView.leftAxis.drawGridLinesEnabled = false
                if minElement != maxElement {
                    self.lineChartView.leftAxis.axisMaximum = maxElement + 10/100*(maxElement-minElement)
                    self.lineChartView.leftAxis.axisMinimum = minElement - 10/100*(maxElement-minElement)
                }
                self.lineChartView.xAxis.labelPosition = Charts.XAxis.LabelPosition.bottom
                
                #if os(iOS)
                    self.lineChartView.extraLeftOffset = 10
                    self.lineChartView.extraRightOffset = 10
                    self.lineChartView.extraBottomOffset = 10
                    
                    self.lineChartView.xAxis.setLabelCount(5, force: true)
                #else
                    self.lineChartView.extraLeftOffset = 30
                    self.lineChartView.extraRightOffset = 30
                    self.lineChartView.extraBottomOffset = 30
                    
                    self.lineChartView.xAxis.labelFont = self.lineChartView.xAxis.labelFont.withSize(30)
                    self.lineChartView.leftAxis.labelFont = self.lineChartView.leftAxis.labelFont.withSize(30)
                #endif
                self.lineChartView.xAxis.avoidFirstLastClippingEnabled = true
                self.lineChartView.xAxis.drawAxisLineEnabled = false
                let granularity = decideTimeGranularityBasedOnData(xs)
                self.lineChartView.xAxis.valueFormatter = DateValueFormatter(granularity: granularity)
                
                self.lineChartView.gridBackgroundColor = NSUIColor.white
                self.lineChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
                self.lineChartView.chartDescription?.text = ""
            
            }
            }
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
        
        #if os(iOS)
            // Only show the table if in Portrait on iPhone
            if(!UIDeviceOrientationIsLandscape(UIDevice.current.orientation)) || UIDevice.current.userInterfaceIdiom == .pad {
                
                let frame:CGRect = CGRect(x: 0, y: 280, width: w, height: h-380)
                self.tableView = UITableView(frame: frame)
                self.tableView?.cellLayoutMarginsFollowReadableWidth = false
                self.tableView?.dataSource = self
                self.tableView?.delegate = self
                self.view.addSubview(self.tableView!)
                
                refreshControl = UIRefreshControl()
                refreshControl.addTarget(self, action: #selector(FeedDetailsViewController.refreshHistFeedData(_:)), for: UIControlEvents.valueChanged)
                self.tableView!.addSubview(refreshControl)
            }
        #endif
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.histItems.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "CELL")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "CELL")
        }
        
        cell!.isUserInteractionEnabled = false
        
        if self.histItems.count > 0 && indexPath.row < self.histItems.count {
            let histItem:JSON =  JSON(self.histItems[indexPath.row])
            
            if let timestamp = histItem["created_at"].string {
                cell!.textLabel?.text = dayTimePeriodFormatterOut.string(from: dayTimePeriodFormatterIn.date(from: timestamp)!)
                
                if let val = histItem["value"].string {
                    cell!.textLabel?.text = (cell!.textLabel?.text)! + "\t\t" + val
                    cell!.textLabel!.isEnabled = true
                }
                
                cell!.textLabel?.font = UIFont(name: "Arial",size:14.0)
            }
        }
        return cell!
        
    }

    @IBAction func onGranularityChange(_ sender: UISegmentedControl) {
        
        let selectedSegment = sender.selectedSegmentIndex
        
        switch selectedSegment {
        case 0:
            limit = "50"
        case 1:
            limit = "100"
        case 2:
            limit = "200"
        case 3:
            limit = "500"
        default:
            limit = "50"
        }
        
        refreshHistFeedData(self)
    }
    
    func decideTimeGranularityBasedOnData(_ xs: [Double]) -> String {
        
        let cal = Calendar.current
        let dayCalendarUnit: NSCalendar.Unit = [.day]
        let dayDifference = (cal as NSCalendar).components(
            dayCalendarUnit,
            from: Date(timeIntervalSince1970: (xs.min())!),
            to: Date(timeIntervalSince1970: (xs.max())!),
            options: [])
        
        if (dayDifference.day! < 1) {
            return "time"
        }
        else {
            return "date"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "editFeed" {
            
            // get a reference to the second view controller
            let editFeedViewController = segue.destination as! EditFeedViewController
            
            // set a variable in the second view controller with the data to pass
            editFeedViewController.selectedFeedName = selectedFeedName
            editFeedViewController.selectedFeedKey = selectedFeedKey
        }
    }

}
