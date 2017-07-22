//
//  PlotSettingsViewController.swift
//  DataFeeds
//
//  Created by Paula on 21/07/2017.
//  Copyright © 2017 monohelixlabs. All rights reserved.
//

import UIKit


class PlotSettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var lineModePicker: UIPickerView!
    
    var pickerData = [
        ["Stepped","Linear","Horizontal Bezier","Cubic Bezier"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        lineModePicker.delegate = self
        lineModePicker.dataSource = self
        
        pickerData = [UserDefaultsManager.sharedInstance.linemodePickerList]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        lineModePicker.selectRow(UserDefaultsManager.sharedInstance.getLineMode(), inComponent: 0, animated: false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print(pickerData[0][lineModePicker.selectedRow(inComponent: 0)])
        UserDefaultsManager.sharedInstance.setLineMode(lineModePicker.selectedRow(inComponent: 0))
    }
}
