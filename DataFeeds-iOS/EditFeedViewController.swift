//
//  EditFeedViewController.swift
//  DataFeeds
//
//  Created by Paula Petcu on 9/8/16.
//  Copyright © 2016 monohelixlabs. All rights reserved.
//

import UIKit

class EditFeedViewController: UIViewController, UITextFieldDelegate {

    var selectedFeedName: String!
    var selectedFeedKey: String!
    
    var currentEmoji: String!
    var newEmoji: String!
    
    let defaultEmoji = String(Character(UnicodeScalar(Int("26AA",radix:16)!)))
    
    let maxEmojiLength = 3
    
    @IBOutlet var emojiTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Edit Feed " + selectedFeedName
        
        let imgPrefs = UserDefaultsManager.sharedInstance.getImagesPreferences()
        
        if let val = imgPrefs[selectedFeedKey!] {
            currentEmoji =  val
         }
         else {
            currentEmoji = defaultEmoji
         }
        
        emojiTextField.text = currentEmoji
        
        self.emojiTextField.delegate = self
        
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        saveEmoji()
        
        return false
    }
    
    @IBAction func saveEmojiButtonPressed(sender: UIButton) {
        
        saveEmoji()
    
    }
    
    func saveEmoji() {
        
        newEmoji = emojiTextField.text! as String
        emojiTextField.endEditing(true)
        
        UserDefaultsManager.sharedInstance.addToImagePreferences(selectedFeedKey,emoji: newEmoji)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        let maxLength = maxEmojiLength
        let currentString: NSString = emojiTextField.text!
        let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
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
