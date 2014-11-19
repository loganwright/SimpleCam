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
    
    private let imageStreamView = UIView()
    private let capturedImagePreview = UIImageView()
    
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
        self.setupCapturedImagePreview()
        self.setupFocusSupport()
    }
    
    func setupView() {
        
        self.view.clipsToBounds = true
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    func setupImageStream() {
        if !DEBUG {
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
        self.setupDevice()
        self.startSession()
    }
    
    func setupDevice() {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        if devices.count > 0 {
            self.myDevice = devices.first as AVCaptureDevice
            self.setupInput()
            self.setupOutput()
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
    
    func setupCapturedImagePreview() {
        if DEBUG {
            self.capturedImagePreview.layer.borderWidth = 5.0
            self.capturedImagePreview.layer.borderColor = UIColor.greenColor().CGColor
        }
        self.capturedImagePreview.userInteractionEnabled = true
        self.capturedImagePreview.backgroundColor = UIColor.clearColor()
        self.capturedImagePreview.contentMode = .ScaleAspectFill
        self.view.addSubview(self.capturedImagePreview)
        self.setupCapturedImagePreviewConstraints()
    }
    
    func setupCapturedImagePreviewConstraints() {
        self.capturedImagePreview.setTranslatesAutoresizingMaskIntoConstraints(false)
        var capturedImagePreviewConstriants = NSLayoutConstraint.layoutConstraintsMatchingBoundsOfView(self.capturedImagePreview, toFrameOfView: self.view)
        self.view.addConstraints(capturedImagePreviewConstriants)
    }
    
    func setupFocusSupport() {
        self.capturedImagePreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleFocusTap:"))
    }
    
    // MARK: Focus Tap
    
    func handleFocusTap(tap: UITapGestureRecognizer) {
        if self.capturedImagePreview.image == nil {
            let point: CGPoint = tap.locationInView(self.imageStreamView)
            if self.myDevice != nil {
                // TODO: Move to setup so this check only runs once
                if self.myDevice.focusPointOfInterestSupported && self.myDevice.exposurePointOfInterestSupported {
                    // we subtract the point from the width to inverse the focal point
                    // focus points of interest represents a CGPoint where
                    // {0,0} corresponds to the top left of the picture area, and
                    // {1,1} corresponds to the bottom right in landscape mode with the home button on the right—
                    // THIS APPLIES EVEN IF THE DEVICE IS IN PORTRAIT MODE
                    // (from docs)
                    // this is all a touch wonky
                    var pX = point.x / CGRectGetWidth(self.imageStreamView.bounds)
                    var pY = point.y / CGRectGetHeight(self.imageStreamView.bounds)
                    var focusX = pY;
                    // x is equal to y but y is equal to inverse x ?
                    var focusY = 1 - pX;
                    
                    var error: NSError?
                    let locked = self.myDevice.lockForConfiguration(&error)
                    if locked {
                        let focusPoint = CGPoint(x: focusX, y: focusY)
                        self.myDevice.focusPointOfInterest = focusPoint
                        if self.myDevice.isFocusModeSupported(.AutoFocus) {
                            self.myDevice.focusMode = .AutoFocus
                        } else {
                            println("LGSimpleCam: .AutoFocus not supported!")
                        }
                        
                        self.myDevice.exposurePointOfInterest = focusPoint
                        if self.myDevice.isExposureModeSupported(.ContinuousAutoExposure) {
                            self.myDevice.exposureMode = .ContinuousAutoExposure
                        } else {
                            println("LGSimpleCam: .ContinuousAutoExposure not supported!")
                        }
                        self.myDevice.unlockForConfiguration()
                    } else if error != nil {
                        println("LGSimpleCam: Error unlocking for focus: \(error!)")
                    } else {
                        println("LGSimpleCam: Unable to unlock to focus")
                    }
                }
            } else {
                println("LGSimpleCam: FocusPOI or ExposurePOI not supported!")
            }
        }
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
