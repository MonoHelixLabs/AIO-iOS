//
//  QRCodeViewController.swift
//  AIO-iOS
//
//  Code for reading QR codes is based on the following article:
//  https://www.appcoda.com/qr-code-reader-swift/
//
//  Created by Paula Petcu on 9/3/16.
//  Copyright © 2016 monohelix. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    
    @IBOutlet var enterCodeButton: UIButton!
    @IBOutlet var codeTextField: UITextField!
    @IBOutlet var saveCodeTextButton: UIButton!
    @IBOutlet var manualEnterStackView: UIStackView!
    @IBOutlet var helpTextLabel: UILabel!
    @IBOutlet var enterModeStackView: UIStackView!
    
    @IBOutlet var scanQRButton: UIButton!
    @IBOutlet var messageLabel: UILabel!
    
    var noQRmessage = "No QR code is detected"
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    // Can support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        helpTextLabel.text = String(Character(UnicodeScalar(Int("2754",radix:16)!))) + " In order to view your feeds from Adafruit IO you will have to provide your AIO key. You can find this key on the io.adafruit.com website. \n\n  You can enter the key manually here or use the Scan QR button below to scan the QR code of your AIO key."
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
        saveCodeTextButton.hidden = false
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
    
    @IBAction func onCodeSavePress(sender: UIButton) {
        
        let aiokey = codeTextField.text! as String
        codeTextField.endEditing(true)
        
        UserDefaultsManager.sharedInstance.setAIOkey(aiokey)
        
        showAIOKeySaveAlert(aiokey)

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
                messageLabel.text = aiokey
                
                stopRecording()
                
                UserDefaultsManager.sharedInstance.setAIOkey(aiokey)
                
                showAIOKeySaveAlert(aiokey)
                
            }
        }
    }
    
    func moveToMainTab() {
        self.tabBarController!.selectedIndex = 0
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
