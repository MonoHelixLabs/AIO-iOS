//
//  QRCodeViewController.swift
//  DataFeeds
//
//  Code for reading QR codes is based on the following article:
//  https://www.appcoda.com/qr-code-reader-swift/
//
//  Created by Paula Petcu on 9/3/16.
//  Copyright © 2016 monohelixlabs. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate {

    
    @IBOutlet var enterCodeButton: UIButton!
    @IBOutlet var codeTextField: UITextField!
    @IBOutlet var manualEnterStackView: UIStackView!
    @IBOutlet var enterModeStackView: UIStackView!
    
    @IBOutlet var scanQRButton: UIButton!
    @IBOutlet var messageLabel: UILabel!
    
    var noQRmessage = "Looking for QR code..."
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    var allowScanning = false
    
    // Can support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        self.codeTextField.delegate = self
        
        UserDefaultsManager.sharedInstance.setShownKeyScreen(true)
        
        checkCamera()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        stopRecording()
        setManualEnterMode()
        
        codeTextField.text = UserDefaultsManager.sharedInstance.getAIOkey()

    }
    
    
    func stopRecording() {
        
        if captureSession?.running == true {
            captureSession?.stopRunning()
            videoPreviewLayer?.removeFromSuperlayer()
            qrCodeFrameView?.removeFromSuperview()
        }
    }
    
    func setManualEnterMode() {
        
        enterCodeButton.highlighted = false
        scanQRButton.highlighted = true
        messageLabel.hidden = true
        manualEnterStackView.hidden = false
        enterCodeButton.hidden = false
        
    }
    
    func setQRScanningMode() {
        
        enterCodeButton.highlighted = true
        scanQRButton.highlighted = false
        messageLabel.text = noQRmessage
        messageLabel.hidden = false
        manualEnterStackView.hidden = true
    }
    
    func showAIOKeySaveAlert(aiokey: String) {
        
        let alertController = UIAlertController(title: "AIO key saved!", message: aiokey, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: {(action) -> Void in self.moveToMainTab()}))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onEnterCodePress(sender: UIButton) {
        
        stopRecording()
        setManualEnterMode()
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        if captureSession?.running == true {
            
            // Change size of the view containing the video preview
            videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height-100)
            
            // Change video orientation
            changeVideoOrientation()
            
        }
    }
    
    func changeVideoOrientation() {
        
        if let connection =  self.videoPreviewLayer?.connection  {
            let previewLayerConnection : AVCaptureConnection = connection
            if (previewLayerConnection.supportsVideoOrientation)
            {
                previewLayerConnection.videoOrientation = getVideoOrientation()
            }
        }
    }
    
    func getVideoOrientation() ->AVCaptureVideoOrientation {
        
        let currentDevice: UIDevice = UIDevice.currentDevice()
        let orientation: UIDeviceOrientation = currentDevice.orientation
        
        switch (orientation)
            {
            case .Portrait:
                return AVCaptureVideoOrientation.Portrait
            case .LandscapeRight:
                return AVCaptureVideoOrientation.LandscapeLeft
            case .LandscapeLeft:
                return AVCaptureVideoOrientation.LandscapeRight
            case .PortraitUpsideDown:
                return AVCaptureVideoOrientation.PortraitUpsideDown
            default:
                return AVCaptureVideoOrientation.Portrait
            }
    }
    
    
    @IBAction func onScanPress(sender: UIButton) {
        
        if (allowScanning == false) {
            return
        }
        
        // Check if we're not already in scanning mode
        if captureSession?.running == true {
            return
        }
        
        setQRScanningMode()
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            
            // Detect all the supported bar code
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            //videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
            changeVideoOrientation()
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-100) //view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture
            captureSession?.startRunning()
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.greenColor().CGColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            
            // Move the message label and the buttons to the top view
            view.bringSubviewToFront(messageLabel)
            view.bringSubviewToFront(enterModeStackView)
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            messageLabel.text = noQRmessage
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // Here we use filter method to check if the type of metadataObj is supported
        // Instead of hardcoding the AVMetadataObjectTypeQRCode, we check if the type
        // can be found in the array of supported bar codes.
        if supportedBarCodes.contains(metadataObj.type) {
            //        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                let aiokey = metadataObj.stringValue
                
                if aiokey.rangeOfCharacterFromSet(NSCharacterSet.alphanumericCharacterSet().invertedSet) == nil {
                
                    messageLabel.text = aiokey
                
                    stopRecording()
                
                    UserDefaultsManager.sharedInstance.setAIOkey(aiokey)
                
                    showAIOKeySaveAlert(aiokey)
                }
                
                else {
                    
                    messageLabel.text = "Not a valid AIO key."
                }
                
            }
        }
    }
    
    func moveToMainTab() {
        self.tabBarController!.selectedIndex = 0
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let aiokey = codeTextField.text! as String
        codeTextField.endEditing(true)
        
        UserDefaultsManager.sharedInstance.setAIOkey(aiokey)
        
        showAIOKeySaveAlert(aiokey)
        
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // guard against anything but alphanumeric characters
        let set = NSCharacterSet.alphanumericCharacterSet().invertedSet
        return string.rangeOfCharacterFromSet(set) == nil
        
    }
    
    func setAllowScanning() {
        allowScanning = true
    }
    
    
    func checkCamera() {
        let authStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch authStatus {
        case .Authorized: setAllowScanning()
        case .Denied: alertToEncourageCameraAccessInitially()
        case .NotDetermined: alertPromptToAllowCameraAccessViaSetting()
        default: alertPromptToAllowCameraAccessViaSetting()
        }
    }
    
    func alertToEncourageCameraAccessInitially() {
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Camera access required for QR Scanning",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .Cancel, handler: { (alert) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func alertPromptToAllowCameraAccessViaSetting() {
        
        let alert = UIAlertController(
            title: "Note",
            message: "You will need to allow camera access in order to use the QR Scanning features.",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel) { alert in
            if AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count > 0 {
                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.checkCamera() } }
            }
            }
        )
        presentViewController(alert, animated: true, completion: nil)
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
