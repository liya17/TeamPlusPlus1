//
//  CameraViewController.swift
//  SidebarMenu
//
//  Created by Izzy Rael on 2/16/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//


import UIKit
import AVFoundation

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var cameraView: UIView!
    
    
    var captureSession : AVCaptureSession?
    var stillImageOutput : AVCaptureStillImageOutput? // to export photo
    var previewLayer : AVCaptureVideoPreviewLayer? // layer onto view to see camera
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())

        } //end if revealviewcontroller
        // Do any additional setup after loading the view
        
    } // end viewDidLoad
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    } // end didReceiveMemoryWarning
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
    } // end viewDidAppear
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080 // resolution
        
        var backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        //var error : NSError?
        var input = try! AVCaptureDeviceInput(device: backCamera)
        
        //if error == nil && captureSession?.canAddInput(input){
        if ((captureSession?.canAddInput(input)) != nil){
            captureSession?.addInput(input)
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings[AVVideoCodecJPEG]
            
            if ((captureSession?.canAddOutput(stillImageOutput)) != nil){
                captureSession?.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) // live camera feed
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect // preserve aspect ratio
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                
                cameraView.layer.addSublayer(previewLayer!)
                captureSession?.startRunning()
            } // end if captureSessionOutput true
            
        } // end if captureSessionInput true
        
        
        
    } // end viewWillAppear
    
    @IBOutlet var tempImageView: UIImageView!
    
    func didPressTakePhoto(){
        if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo){
            
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                
                if sampleBuffer != nil{
                    var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    var dataProvider = CGDataProviderCreateWithCFData(imageData)
                    var cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, .RenderingIntentDefault)
                    
                    var image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    
                    self.tempImageView.image = image
                    self.tempImageView.hidden = false
                }
                
            })
        } // end let view
        
    } // end didPressTakePhoto
    
    var didTakePhoto = Bool()
    func didPressTakeAnother(){
        
        if didTakePhoto == true {
            self.tempImageView.hidden = true
            didTakePhoto = false
            
            
        } // end if
            
        else {
            captureSession!.startRunning()
            didTakePhoto = true
            didPressTakePhoto()
        } // end else
        
    } // end didPressTakeAnother
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        didPressTakeAnother()
    }
    
    
    
    
} // end ViewController2
