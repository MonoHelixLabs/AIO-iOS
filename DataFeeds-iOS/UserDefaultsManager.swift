//
//  UserDefaultsManager.swift
//  DataFeeds
//
//  Created by Paula Petcu on 9/4/16.
//  Copyright © 2016 monohelixlabs. All rights reserved.
//

import Foundation

class UserDefaultsManager: NSObject {
    
    static let sharedInstance = UserDefaultsManager()
    
    let aiokeyString = "aiokey"
    let aiokeyNotFound = ""
    
    let imgPrefsString = "imageprefs"
    
    let shownKeyScreenString = "shownkeyscreen"
    
    let mainfeedrefreshString = "mainfeedrefresh"
    let mainfeedrefreshdefault = 0
    let feeddetailsrefreshString = "feeddetailsrefresh"
    let feeddetailsrefreshdefault = 0
    
    let refreshRates = [0.0, 15.0, 30.0, 60.0, 120.0]
    
    func getAIOkey() -> String {
 
        let iCloudKeyStore: NSUbiquitousKeyValueStore? = NSUbiquitousKeyValueStore()
        if let savedAIOkey = iCloudKeyStore!.stringForKey(aiokeyString) {
            return savedAIOkey
        }
        else {
            let prefs = NSUserDefaults.standardUserDefaults()
            var key = prefs.stringForKey(aiokeyString)
            if (key == nil) { key = aiokeyNotFound }
            return key!
        }
    }
    
    func setAIOkey(aiokey: String) {
        
        let iCloudKeyStore: NSUbiquitousKeyValueStore? = NSUbiquitousKeyValueStore()
        iCloudKeyStore!.setString(aiokey, forKey: aiokeyString)
        iCloudKeyStore!.synchronize()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(aiokey, forKey: aiokeyString)
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    func getImagesPreferences() -> [String:String]{
        
        let iCloudKeyStore: NSUbiquitousKeyValueStore? = NSUbiquitousKeyValueStore()
        if let imagePrefs = iCloudKeyStore!.dictionaryForKey(imgPrefsString) {
            return (imagePrefs as! [String:String])
        }
        else {
            let prefs = NSUserDefaults.standardUserDefaults()
        
            if let imagePrefs = prefs.dictionaryForKey(imgPrefsString) {
                return (imagePrefs as! [String:String])
            }
            else {
                return [:]
            }
        }
    }
    
    func addToImagePreferences(feed: String, emoji: String) {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        
        if var imagePrefs = prefs.dictionaryForKey(imgPrefsString) {
            imagePrefs[feed] = emoji
            setImagesPreferences(imagePrefs as! [String:String])
        }
        else {
            var imagePrefs = [String:String]()
            imagePrefs[feed] = emoji
            setImagesPreferences(imagePrefs)
        }
    }
    
    func setImagesPreferences(prefs: [String:String]) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(prefs, forKey: imgPrefsString)
        NSUserDefaults.standardUserDefaults().synchronize()
        let iCloudKeyStore: NSUbiquitousKeyValueStore? = NSUbiquitousKeyValueStore()
        iCloudKeyStore!.setObject(prefs, forKey: imgPrefsString)
        iCloudKeyStore!.synchronize()
        
    }
    
    func syncWithiCloud() {
        
        let iCloudKeyStore: NSUbiquitousKeyValueStore? = NSUbiquitousKeyValueStore()
        let prefs = NSUserDefaults.standardUserDefaults()
        if let savedAIOkey = iCloudKeyStore!.stringForKey(aiokeyString) {
            prefs.setObject(savedAIOkey, forKey: aiokeyString)
        }
        if let imagePrefs = iCloudKeyStore!.dictionaryForKey(imgPrefsString) {
            prefs.setObject(imagePrefs, forKey: imgPrefsString)
        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    func getStringFromEmoji(emoji: String) -> String {
        return String(Character(UnicodeScalar(Int(emoji,radix:16)!)))
    }
    
    // Preferences that are not synced with iCloud follow
    
    func getShownKeyScreen() -> Bool {
        let prefs = NSUserDefaults.standardUserDefaults()
        let shownKeyScreen = prefs.boolForKey(shownKeyScreenString)
        return shownKeyScreen
    }
    
    func setShownKeyScreen(shownKeyScreen: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(shownKeyScreen, forKey: shownKeyScreenString)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getRefreshRateMainFeed() -> Int {
        let prefs = NSUserDefaults.standardUserDefaults()
        var mainfeedrefresh = prefs.integerForKey(mainfeedrefreshString)
        if (mainfeedrefresh == 0) { mainfeedrefresh = mainfeedrefreshdefault }
        return mainfeedrefresh
    }
    
    func getRefreshRateMainFeedToInterval() -> Double {
        return refreshRates[getRefreshRateMainFeed()]
    }
    
    func getRefreshRateFeedDetailsToInterval() -> Double {
        return refreshRates[getRefreshRateDetailsFeed()]
    }
    
    func setRefreshRateMainFeed(value: Int) {
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setObject(value, forKey: mainfeedrefreshString)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getRefreshRateDetailsFeed() -> Int{
        let prefs = NSUserDefaults.standardUserDefaults()
        var feeddetailsrefresh = prefs.integerForKey(feeddetailsrefreshString)
        if (feeddetailsrefresh == 0) { feeddetailsrefresh = feeddetailsrefreshdefault }
        return feeddetailsrefresh
    }
    
    func setRefreshRateDetailsFeed(value: Int) {
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setObject(value, forKey: feeddetailsrefreshString)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    
}
