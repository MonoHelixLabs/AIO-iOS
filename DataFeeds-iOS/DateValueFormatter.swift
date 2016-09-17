//
//  DateValueFormatter.swift
//  DataFeeds
//
//  Created by Paula Petcu on 9/9/16.
//  Copyright © 2016 monohelixlabs. All rights reserved.
//

import Foundation
import Charts

class DateValueFormatter: NSObject, IAxisValueFormatter {
    
    let dateFormatter = NSDateFormatter()
    let dateTimePeriodFormatterDateFormat = "MMM dd YYYY HH:mm:ss"
    let timePeriodFormatterDateFormat = "HH:mm:ss"
    
    init(granularity: String) {
        
        switch granularity {
        case "datetime":
            dateFormatter.dateFormat = dateTimePeriodFormatterDateFormat
        case "time":
            dateFormatter.dateFormat = timePeriodFormatterDateFormat
        default:
            dateFormatter.dateFormat = dateTimePeriodFormatterDateFormat
        }
        
        super.init()
    }
    
    func stringForValue(value: Double, axis: AxisBase?) -> String {
        return dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: value))
    }
    
}
