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
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        self.codeTextField.delegate = self
        
        UserDefaultsManager.sharedInstance.setShownKeyScreen(true)
        
        checkCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        stopRecording()
        setManualEnterMode()
        
        codeTextField.text = UserDefaultsManager.sharedInstance.getAIOkey()

    }
    
    
    func stopRecording() {
        
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
            videoPreviewLayer?.removeFromSuperlayer()
            qrCodeFrameView?.removeFromSuperview()
        }
    }
    
    func setManualEnterMode() {
        
        enterCodeButton.isHighlighted = false
        scanQRButton.isHighlighted = true
        messageLabel.isHidden = true
        manualEnterStackView.isHidden = false
        enterCodeButton.isHidden = false
        
    }
    
    func setQRScanningMode() {
        
        enterCodeButton.isHighlighted = true
        scanQRButton.isHighlighted = false
        messageLabel.text = noQRmessage
        messageLabel.isHidden = false
        manualEnterStackView.isHidden = true
    }
    
    func showAIOKeySaveAlert(_ aiokey: String) {
        
        let alertController = UIAlertController(title: "AIO key saved!", message: aiokey, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: {(action) -> Void in self.moveToMainTab()}))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onEnterCodePress(_ sender: UIButton) {
        
        stopRecording()
        setManualEnterMode()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if captureSession?.isRunning == true {
            
            // Change size of the view containing the video preview
            videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height-100)
            
            // Change video orientation
            changeVideoOrientation()
            
        }
    }
    
    func changeVideoOrientation() {
        
        if let connection =  self.videoPreviewLayer?.connection  {
            let previewLayerConnection : AVCaptureConnection = connection
            if (previewLayerConnection.isVideoOrientationSupported)
            {
                previewLayerConnection.videoOrientation = getVideoOrientation()
            }
        }
    }
    
    func getVideoOrientation() ->AVCaptureVideoOrientation {
        
        let currentDevice: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = currentDevice.orientation
        
        switch (orientation)
            {
            case .portrait:
                return AVCaptureVideoOrientation.portrait
            case .landscapeRight:
                return AVCaptureVideoOrientation.landscapeLeft
            case .landscapeLeft:
                return AVCaptureVideoOrientation.landscapeRight
            case .portraitUpsideDown:
                return AVCaptureVideoOrientation.portraitUpsideDown
            default:
                return AVCaptureVideoOrientation.portrait
            }
    }
    
    
    @IBAction func onScanPress(_ sender: UIButton) {
        
        if (allowScanning == false) {
            return
        }
        
        // Check if we're not already in scanning mode
        if captureSession?.isRunning == true {
            return
        }
        
        setQRScanningMode()
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
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
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
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
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
            // Move the message label and the buttons to the top view
            view.bringSubview(toFront: messageLabel)
            view.bringSubview(toFront: enterModeStackView)
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
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
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                let aiokey = metadataObj.stringValue
                
                if aiokey?.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil {
                
                    messageLabel.text = aiokey
                
                    stopRecording()
                
                    UserDefaultsManager.sharedInstance.setAIOkey(aiokey!)
                
                    showAIOKeySaveAlert(aiokey!)
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let aiokey = codeTextField.text! as String
        codeTextField.endEditing(true)
        
        UserDefaultsManager.sharedInstance.setAIOkey(aiokey)
        
        showAIOKeySaveAlert(aiokey)
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // guard against anything but alphanumeric characters
        let set = CharacterSet.alphanumerics.inverted
        return string.rangeOfCharacter(from: set) == nil
        
    }
    
    func setAllowScanning() {
        allowScanning = true
    }
    
    
    func checkCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authStatus {
        case .authorized: setAllowScanning()
        case .denied: alertToEncourageCameraAccessInitially()
        case .notDetermined: alertPromptToAllowCameraAccessViaSetting()
        default: alertPromptToAllowCameraAccessViaSetting()
        }
    }
    
    func alertToEncourageCameraAccessInitially() {
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Camera access required for QR Scanning",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func alertPromptToAllowCameraAccessViaSetting() {
        
        let alert = UIAlertController(
            title: "Note",
            message: "You will need to allow camera access in order to use the QR Scanning features.",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { alert in
            if AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).count > 0 {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
                    DispatchQueue.main.async {
                        self.checkCamera() } }
            }
            }
        )
        present(alert, animated: true, completion: nil)
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
