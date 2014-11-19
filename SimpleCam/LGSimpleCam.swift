//
//  LGSimpleCam.swift
//  SimpleCam
//
//  Created by Logan Wright on 11/16/14.
//  Copyright (c) 2014 Logan Wright. All rights reserved.
//

import UIKit
import AVFoundation

var DEBUG = true

extension UIScreen {
    var screenWidth: CGFloat {
        return CGRectGetWidth(UIScreen.mainScreen().bounds)
    }
    var screenHeight: CGFloat {
        return CGRectGetHeight(UIScreen.mainScreen().bounds)
    }
}

class LGSimpleCam: UIViewController {
    
    // MARK: Image Resize Flags
    
    private var isImageResized = false
    private var isSaveWaitingForResizedImage = false
    private var isRotateWaitingForResizedImage = false
    
    // MARK: Capture Flags
    
    private var isCapturingImage = false
    
    // MARK: Private Properties
    
    private let mySesh = AVCaptureSession()
    private let stillImageOutput = AVCaptureStillImageOutput()
    private var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var myDevice: AVCaptureDevice!
    
    // MARK: Views
    
    var imageStreamView = UIView()
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    // MARK: Setup
    
    func setup() {
        self.setupView()
        self.setupImageStream()
        self.setupCaptureVideoPreviewLayer()
        self.setupSession()
        self.startSession()
    }
    
    func setupView() {
        
        self.view.clipsToBounds = true
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    func setupImageStream() {
        if DEBUG {
//            self.imageStreamView.backgroundColor = UIColor.cyanColor()
            self.imageStreamView.layer.borderWidth = 5.0
            self.imageStreamView.layer.borderColor = UIColor.redColor().CGColor
        }
        else {
            self.imageStreamView.alpha = 0.0
        }
        self.imageStreamView.layer.addSublayer(self.captureVideoPreviewLayer)
        self.view.addSubview(self.imageStreamView)
        self.setupImageStreamConstraints()
    }
    
    func setupImageStreamConstraints() {
        self.imageStreamView.setTranslatesAutoresizingMaskIntoConstraints(false)
        var imageStreamConstraints = NSLayoutConstraint.layoutConstraintsMatchingBoundsOfView(self.imageStreamView, toFrameOfView: self.view)
        self.view.addConstraints(imageStreamConstraints)
    }
    
    func setupCaptureVideoPreviewLayer() {
        self.captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.mySesh)
        self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.captureVideoPreviewLayer.frame = self.imageStreamView.bounds
        self.imageStreamView.layer.addSublayer(self.captureVideoPreviewLayer)
    }
    
    func setupSession() {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        if devices.count > 0 {
            self.myDevice = devices.first as AVCaptureDevice
            self.setupInput()
        } else {
            println("LGSimpleCam: Unable to find device!")
        }
    }
    
    func setupInput() {
        var error: NSError? = nil
        let input: AVCaptureDeviceInput? = AVCaptureDeviceInput.deviceInputWithDevice(myDevice, error: &error) as? AVCaptureDeviceInput
        if error == nil {
            self.mySesh.addInput(input)
        } else {
            println("LGSimpleCam: Error loading input!")
        }
    }
    
    func setupOutput() {
        self.stillImageOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        self.mySesh.addOutput(self.stillImageOutput)
    }
    
    func startSession() {
        self.mySesh.startRunning()
        
        // TODO: Vary based on orientation
        self.captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
    }
    
    // MARK: Rotation
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willAnimateRotationToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        self.captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: toInterfaceOrientation)
        self.captureVideoPreviewLayer.frame = self.imageStreamView.bounds
    }
    
    // MARK: Subview Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.captureVideoPreviewLayer.frame = self.imageStreamView.bounds
    }
    
    // MARK: Status Bar Preference
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

extension AVCaptureVideoOrientation {
    init(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .LandscapeLeft:
            self = .LandscapeLeft
        case .LandscapeRight:
            self = .LandscapeRight
        case .Portrait:
            self = .Portrait
        case .PortraitUpsideDown:
            self = .PortraitUpsideDown
        case .Unknown:
            self = .Portrait
        }
    }
}

extension NSLayoutConstraint {
    class func layoutConstraintsMatchingBoundsOfView(boundsView: UIView, toFrameOfView frameView: UIView) -> [NSLayoutConstraint] {
        
        var top = NSLayoutConstraint(item: boundsView, attribute: .Top, relatedBy: .Equal, toItem: frameView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        var left = NSLayoutConstraint(item: boundsView, attribute: .Left, relatedBy: .Equal, toItem: frameView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        var bottom = NSLayoutConstraint(item: boundsView, attribute: .Bottom, relatedBy: .Equal, toItem: frameView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        var right = NSLayoutConstraint(item: boundsView, attribute: .Right, relatedBy: .Equal, toItem: frameView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        return [top, left, bottom, right]
    }
}
