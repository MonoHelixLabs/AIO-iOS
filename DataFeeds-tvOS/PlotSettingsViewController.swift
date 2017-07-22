//
//  PlotSettingsViewController.swift
//  DataFeeds
//
//  Created by Paula on 22/07/2017.
//  Copyright © 2017 monohelixlabs. All rights reserved.
//

import UIKit

class PlotSettingsViewController: UIViewController {

    
    @IBOutlet weak var lineModeControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        lineModeControl.selectedSegmentIndex = UserDefaultsManager.sharedInstance.getLineMode()
    }
    
    
    @IBAction func onLineModeChanged(_ sender: UISegmentedControl) {
        
        UserDefaultsManager.sharedInstance.setLineMode(sender.selectedSegmentIndex)
    }
    
}

