//
//  RefreshRateViewController.swift
//  DataFeeds
//
//  Created by Paula Petcu on 10/9/16.
//  Copyright © 2016 monohelixlabs. All rights reserved.
//

import UIKit

class RefreshRateViewController: UIViewController {

    #if os(iOS)
        @IBOutlet var mainFeedRefreshControl: UISegmentedControl!
        @IBOutlet var feedDetailsRefreshControl: UISegmentedControl!
    #else
        @IBOutlet var mainFeedRefreshControl: UISegmentedControl!
        @IBOutlet var feedDetailsRefreshControl: UISegmentedControl!
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
    }

    override func viewDidAppear(_ animated: Bool) {
        
        mainFeedRefreshControl.selectedSegmentIndex = UserDefaultsManager.sharedInstance.getRefreshRateMainFeed()
    }
    
    #if os(iOS)
    @IBAction func onMainFeedRefreshRateChanged(_ sender: UISegmentedControl) {
        
        UserDefaultsManager.sharedInstance.setRefreshRateMainFeed(sender.selectedSegmentIndex)
    }
    @IBAction func onFeedDetailsRefreshRateChanged(_ sender: UISegmentedControl) {
        
        UserDefaultsManager.sharedInstance.setRefreshRateDetailsFeed(sender.selectedSegmentIndex)
    }
    #else
    @IBAction func onMainFeedRefreshRateChanged(_ sender: UISegmentedControl) {
    
        UserDefaultsManager.sharedInstance.setRefreshRateMainFeed(sender.selectedSegmentIndex)
    }
    @IBAction func onFeedDetailsRefreshRateChanged(_ sender: UISegmentedControl) {
    
        UserDefaultsManager.sharedInstance.setRefreshRateDetailsFeed(sender.selectedSegmentIndex)
    }
    #endif
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
