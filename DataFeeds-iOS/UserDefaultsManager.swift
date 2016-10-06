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
    let mainfeedrefreshString = "mainfeedrefresh"
    let feeddetailsrefreshString = "feeddetailsrefresh"
        
    let shownKeyScreenString = "shownkeyscreen"
    
    func getAIOkey() -> String {
 
        let prefs = NSUserDefaults.standardUserDefaults()
        var key = prefs.stringForKey(aiokeyString)
        if (key == nil) { key = aiokeyNotFound }
        return key!
    }
    
    func setAIOkey(aiokey: String) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(aiokey, forKey: aiokeyString)
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    func getImagesPreferences() -> [String:String]{
        
        let prefs = NSUserDefaults.standardUserDefaults()
        
        if let imagePrefs = prefs.dictionaryForKey(imgPrefsString) {
            return (imagePrefs as! [String:String])
        }
        else {
            return [:]
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
    }
    
    func getStringFromEmoji(emoji: String) -> String {
        return String(Character(UnicodeScalar(Int(emoji,radix:16)!)))
    }
    
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
    
}
