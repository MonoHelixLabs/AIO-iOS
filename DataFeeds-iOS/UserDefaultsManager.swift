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
    
    let linemodeString = "linemode"
    let linemodedefault = 2
    let linemodePickerList = ["Stepped","Linear","Horizontal Bezier","Cubic Bezier"]
    
    //
    // Preferences that are synced with iCloud
    //
    
    // AIO key
    
    func getAIOkey() -> String {
 
        let iCloudKeyStore: NSUbiquitousKeyValueStore? = NSUbiquitousKeyValueStore()
        if let savedAIOkey = iCloudKeyStore!.string(forKey: aiokeyString) {
            return savedAIOkey
        }
        else {
            let prefs = UserDefaults.standard
            var key = prefs.string(forKey: aiokeyString)
            if (key == nil) { key = aiokeyNotFound }
            return key!
        }
    }
    
    func setAIOkey(_ aiokey: String) {
        
        let iCloudKeyStore: NSUbiquitousKeyValueStore? = NSUbiquitousKeyValueStore()
        iCloudKeyStore!.set(aiokey, forKey: aiokeyString)
        iCloudKeyStore!.synchronize()
        
        let defaults = UserDefaults.standard
        defaults.set(aiokey, forKey: aiokeyString)
        UserDefaults.standard.synchronize()
        
    }
    
    // Feed emojis
    
    func getImagesPreferences() -> [String:String]{
        
        let iCloudKeyStore: NSUbiquitousKeyValueStore? = NSUbiquitousKeyValueStore()
        if let imagePrefs = iCloudKeyStore!.dictionary(forKey: imgPrefsString) {
            return (imagePrefs as! [String:String])
        }
        else {
            let prefs = UserDefaults.standard
        
            if let imagePrefs = prefs.dictionary(forKey: imgPrefsString) {
                return (imagePrefs as! [String:String])
            }
            else {
                return [:]
            }
        }
    }
    
    func addToImagePreferences(_ feed: String, emoji: String) {
        
        let prefs = UserDefaults.standard
        
        if var imagePrefs = prefs.dictionary(forKey: imgPrefsString) {
            imagePrefs[feed] = emoji
            setImagesPreferences(imagePrefs as! [String:String])
        }
        else {
            var imagePrefs = [String:String]()
            imagePrefs[feed] = emoji
            setImagesPreferences(imagePrefs)
        }
    }
    
    func setImagesPreferences(_ prefs: [String:String]) {
        
        let defaults = UserDefaults.standard
        defaults.set(prefs, forKey: imgPrefsString)
        UserDefaults.standard.synchronize()
        let iCloudKeyStore: NSUbiquitousKeyValueStore? = NSUbiquitousKeyValueStore()
        iCloudKeyStore!.set(prefs, forKey: imgPrefsString)
        iCloudKeyStore!.synchronize()
        
    }
    
    // Helper functions
    
    func syncWithiCloud() {
        
        let iCloudKeyStore: NSUbiquitousKeyValueStore? = NSUbiquitousKeyValueStore()
        let prefs = UserDefaults.standard
        if let savedAIOkey = iCloudKeyStore!.string(forKey: aiokeyString) {
            prefs.set(savedAIOkey, forKey: aiokeyString)
        }
        if let imagePrefs = iCloudKeyStore!.dictionary(forKey: imgPrefsString) {
            prefs.set(imagePrefs, forKey: imgPrefsString)
        }
        
        UserDefaults.standard.synchronize()
        
    }
    
    func getStringFromEmoji(_ emoji: String) -> String {
        return String(Character(UnicodeScalar(Int(emoji,radix:16)!)!))
    }
    
    //
    // Preferences that are not synced with iCloud follow
    //
    
    func getShownKeyScreen() -> Bool {
        let prefs = UserDefaults.standard
        let shownKeyScreen = prefs.bool(forKey: shownKeyScreenString)
        return shownKeyScreen
    }
    
    func setShownKeyScreen(_ shownKeyScreen: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(shownKeyScreen, forKey: shownKeyScreenString)
        UserDefaults.standard.synchronize()
    }
    
    // Refresh Rate
    
    func getRefreshRateMainFeedToInterval() -> Double {
        return refreshRates[getRefreshRateMainFeed()]
    }
    
    func getRefreshRateFeedDetailsToInterval() -> Double {
        return refreshRates[getRefreshRateDetailsFeed()]
    }
    
    func getRefreshRateMainFeed() -> Int {
        let prefs = UserDefaults.standard
        var mainfeedrefresh = prefs.integer(forKey: mainfeedrefreshString)
        if (mainfeedrefresh == 0) { mainfeedrefresh = mainfeedrefreshdefault }
        return mainfeedrefresh
    }
    
    func setRefreshRateMainFeed(_ value: Int) {
        let prefs = UserDefaults.standard
        prefs.set(value, forKey: mainfeedrefreshString)
        UserDefaults.standard.synchronize()
    }
    
    func getRefreshRateDetailsFeed() -> Int{
        let prefs = UserDefaults.standard
        var feeddetailsrefresh = prefs.integer(forKey: feeddetailsrefreshString)
        if (feeddetailsrefresh == 0) { feeddetailsrefresh = feeddetailsrefreshdefault }
        return feeddetailsrefresh
    }
    
    func setRefreshRateDetailsFeed(_ value: Int) {
        let prefs = UserDefaults.standard
        prefs.set(value, forKey: feeddetailsrefreshString)
        UserDefaults.standard.synchronize()
    }
    
    // Line Mode
    
    func getLineMode() -> Int {
        let prefs = UserDefaults.standard
        var linemode = prefs.integer(forKey: linemodeString)
        if (linemode == 0) { linemode = linemodedefault }
        return linemode
    }
    
    func setLineMode(_ value: Int) {
        let prefs = UserDefaults.standard
        prefs.set(value, forKey: linemodeString)
        UserDefaults.standard.synchronize()
    }
    
}
