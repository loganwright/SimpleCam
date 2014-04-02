//
//  SimpleCam.m
//  SimpleCam
//
//  Created by Logan Wright on 2/1/14.
//  Copyright (c) 2014 Logan Wright. All rights reserved.
//
//  Mozilla Public License v2.0
//
//  **
//
//  PLEASE FAMILIARIZE YOURSELF WITH THE ----- Mozilla Public License v2.0
//
//  **
//
//  Attribution is satisfied by acknowledging the use of SimpleCam,
//  or its creation by Logan Wright
//
//  **
//
//  You can use, modify and redistribute this code in your product,
//  but to satisfy the requirements of Mozilla Public License v2.0,
//  it is required to provide the source code for any fixes you make to it.
//
//  **
//
//  Covered Software is provided under this License on an “as is” basis, without warranty of any
//  kind, either expressed, implied, or statutory, including, without limitation, warranties that
//  the Covered Software is free of defects, merchantable, fit for a particular purpose or non-
//  infringing. The entire risk as to the quality and performance of the Covered Software is with
//  You. Should any Covered Software prove defective in any respect, You (not any Contributor)
//  assume the cost of any necessary servicing, repair, or correction. This disclaimer of
//  warranty constitutes an essential part of this License. No use of any Covered Software is
//  authorized under this License except under this disclaimer.
//
//  **
//

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#import "SimpleCam.h"

@interface SimpleCam ()

{
    // Images
    UIImage * lighteningImg;
    UIImage * cameraRotateImg;
    UIImage * downloadImg;
    UIImage * previousImg;
    
    // Controls
    UIButton * backBtn;
    UIButton * captureBtn;
    UIButton * flashBtn;
    UIButton * switchCameraBtn;
    UIButton * saveBtn;
    
    // Measurements
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat topX;
    CGFloat topY;
    
    // Resize Toggles
    BOOL isImageResized;
    BOOL isSaveWaitingForResizedImage;
    BOOL isRotateWaitingForResizedImage;
    
    // Capture Toggle
    BOOL isCapturingImage;
    
    // Used to cover animation flicker
    CALayer * previewCoverLayer;
    
    // Square Border
    UIView * squareV;
}

// AVFoundation Properties
@property (strong, nonatomic) AVCaptureSession * mySesh;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureDevice * myDevice;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer * captureVideoPreviewLayer;

// View Properties
@property (strong, nonatomic) UIView * imageStreamV;
@property (strong, nonatomic) UIImageView * capturedImageV;

@end

@implementation SimpleCam;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    previousImg = [UIImage imageNamed:@"Previous.png"];
    downloadImg = [UIImage imageNamed:@"Download.png"];
    lighteningImg = [UIImage imageNamed:@"Lightening.png"];
    cameraRotateImg = [UIImage imageNamed:@"CameraRotate.png"]; 
    
    BOOL isLandscape = NO;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        isLandscape = YES;
    }
    
	// Do any additional setup after loading the view.
    screenWidth = self.view.bounds.size.width;
    screenHeight = self.view.bounds.size.height;
    
    if (isLandscape) self.view.frame = CGRectMake(0, 0, screenHeight, screenWidth);
    
    if (_imageStreamV == nil) _imageStreamV = [[UIView alloc]init];
    _imageStreamV.alpha = 0;
    _imageStreamV.frame = self.view.bounds;
    [self.view addSubview:_imageStreamV];
    
    
    if (_capturedImageV == nil) _capturedImageV = [[UIImageView alloc]init];
    _capturedImageV.frame = _imageStreamV.frame; // just to even it out
    _capturedImageV.backgroundColor = [UIColor clearColor];
    _capturedImageV.userInteractionEnabled = YES;
    _capturedImageV.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:_capturedImageV aboveSubview:_imageStreamV];
    
    // for focus
    UITapGestureRecognizer * focusTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSent:)];
    focusTap.numberOfTapsRequired = 1;
    [_capturedImageV addGestureRecognizer:focusTap];
    
    // SETTING UP CAM
    if (_mySesh == nil) _mySesh = [[AVCaptureSession alloc] init];
	_mySesh.sessionPreset = AVCaptureSessionPresetPhoto;
    
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_mySesh];
	_captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	_captureVideoPreviewLayer.frame = _imageStreamV.layer.bounds; // parent of layer
    
	[_imageStreamV.layer addSublayer:_captureVideoPreviewLayer];
	
    // rear camera: 0 front camera: 1
    _myDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0];
    
    if ([_myDevice isFlashAvailable] && _myDevice.flashActive && [_myDevice lockForConfiguration:nil]) {
        //NSLog(@"SC: Turning Flash Off ...");
        _myDevice.flashMode = AVCaptureFlashModeOff;
        [_myDevice unlockForConfiguration];
    }
    
    NSError * error = nil;
	AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:_myDevice error:&error];
    
	if (!input) {
		// Handle the error appropriately.
		NSLog(@"SC: ERROR: trying to open camera: %@", error);
        [_delegate closeSimpleCam:self withImage:nil];
	}
    
	[_mySesh addInput:input];
    
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    [_mySesh addOutput:_stillImageOutput];
    
    
	[_mySesh startRunning];
    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }
    
    [self prepareControls];
    
    if (_isSquareMode) {
        NSLog(@"SC: isSquareMode");
        squareV = [[UIView alloc]init];
        squareV.backgroundColor = [UIColor clearColor];
        squareV.layer.borderWidth = 4;
        squareV.layer.borderColor = [UIColor colorWithWhite:1 alpha:.8].CGColor;
        squareV.bounds = CGRectMake(0, 0, screenWidth, screenWidth);
        squareV.center = self.view.center;
        
        squareV.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        [self.view addSubview:squareV];
    }
    
    /* To Block Rotation Animation Flicker */
    UIView * streamCover = [UIView new];
    streamCover.backgroundColor = [UIColor blackColor];
    streamCover.bounds = CGRectMake(0, 0, screenHeight * 3, screenHeight * 3); // 1 full screen size either direction
    streamCover.center = self.view.center;
    streamCover.autoresizingMask = UIViewAutoresizingNone;
    self.view.clipsToBounds = NO;
    [self.view insertSubview:streamCover belowSubview:_imageStreamV];
}

- (void) viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _imageStreamV.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished) {
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"SC: DID RECIEVE MEMORY WARNING");
    // Dispose of any resources that can be recreated.
}

#pragma mark CAMERA CONTROLS

- (void) prepareControls {
    
    backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [backBtn addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:previousImg forState:UIControlStateNormal];
    [backBtn setTintColor:[self redColor]];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(9, 10, 9, 13)];
    // btn is 40 x 40 , img is 22 x 40 (18 x 20)
    
    flashBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [flashBtn addTarget:self action:@selector(flashBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [flashBtn setImage:lighteningImg forState:UIControlStateNormal];
    [flashBtn setTintColor:[self redColor]];
    [flashBtn setImageEdgeInsets:UIEdgeInsetsMake(6, 9, 6, 9)];
    // btn is 40 x 40 , img is 36 x 54 (18 x 26)
    
    
    switchCameraBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [switchCameraBtn setImage:cameraRotateImg forState:UIControlStateNormal];
    [switchCameraBtn setTintColor:[self blueColor]];
    [switchCameraBtn setImageEdgeInsets:UIEdgeInsetsMake(9.5, 7, 9.5, 7)];
    
    // btn is 40 x 40 , img is 54 x 42 (26 x 21)
    
    saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveBtn addTarget:self action:@selector(saveBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn setImage:downloadImg forState:UIControlStateNormal];
    [saveBtn setTintColor:[self blueColor]];
    [saveBtn setImageEdgeInsets:UIEdgeInsetsMake(7, 10.5, 7, 10.5)];
    // btn is 40 x 40 , img is 38 x 54 (19 x 26)
    
    captureBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [captureBtn addTarget:self action:@selector(captureBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [captureBtn setTitle:@"C\nA\nP\nT\nU\nR\nE" forState:UIControlStateNormal];
    [captureBtn setTitleColor:[self darkGreyColor] forState:UIControlStateNormal];
    captureBtn.titleLabel.font = [UIFont systemFontOfSize:12.5];
    captureBtn.titleLabel.numberOfLines = 0;
    captureBtn.titleLabel.minimumScaleFactor = .5;
    
    // Stylize buttons
    for (UIButton * v in @[backBtn, captureBtn, flashBtn, switchCameraBtn, saveBtn])  {
        
        v.backgroundColor = [UIColor colorWithWhite:1 alpha:.96];
        v.layer.cornerRadius = 4;
        v.layer.shadowColor= [UIColor colorWithWhite:0 alpha:.45].CGColor;
        v.layer.shadowOpacity = 1;
        v.layer.shadowRadius = 1;
        v.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:v.bounds cornerRadius:4].CGPath;//bezierPathWithRect:v.bounds].CGPath;
        v.layer.shadowOffset = CGSizeMake(0, 0.5);
        v.layer.rasterizationScale = [UIScreen mainScreen].scale;
        v.layer.shouldRasterize = YES;
        
        v.alpha = .6;
        
        v.hidden = YES;
        
        v.bounds = CGRectMake(0, 0, 40, 40);
        
        [self.view addSubview:v];
    }
    
    // If a device doesn't have multiple cameras, fade out button ...
    if ([AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count == 1) {
        switchCameraBtn.alpha = 0.2;
    }
    else {
        [switchCameraBtn addTarget:self action:@selector(switchCameraBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self drawControls];
}

- (void) drawControls {
    
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            
            CGFloat centerY = screenHeight - 8 - 20; // 8 is offset, 20 is half btn height
            
            // offset from side is '10'
            backBtn.center = CGPointMake(10 + (backBtn.bounds.size.width / 2), centerY);
            
            // offset from backbtn is '20'
            [captureBtn setTitle:@"CAPTURE" forState:UIControlStateNormal];
            captureBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
            captureBtn.bounds = CGRectMake(0, 0, 120, 40);
            captureBtn.center = CGPointMake(backBtn.center.x + (backBtn.bounds.size.width / 2) + 20 + (captureBtn.bounds.size.width / 2), centerY);
            
            // offset from capturebtn is '20'
            flashBtn.center = CGPointMake(captureBtn.center.x + (captureBtn.bounds.size.width / 2) + 20 + (flashBtn.bounds.size.width / 2), centerY);
            
            // offset from flashBtn is '20'
            switchCameraBtn.center = CGPointMake(flashBtn.center.x + (flashBtn.bounds.size.width / 2) + 20 + (switchCameraBtn.bounds.size.width / 2), centerY);
            
        }
        else if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            CGFloat centerX = screenHeight - 8 - 20; // 8 is offset, 20 is half btn height
            
            // offset from side is '10'
            backBtn.center = CGPointMake(centerX, 10 + (backBtn.bounds.size.height / 2));
            
            // offset from backbtn is '20'
            [captureBtn setTitle:@"C\nA\nP\nT\nU\nR\nE" forState:UIControlStateNormal];
            captureBtn.titleLabel.font = [UIFont systemFontOfSize:12.5];
            captureBtn.bounds = CGRectMake(0, 0, 40, 120);
            captureBtn.center = CGPointMake(centerX, backBtn.center.y + (backBtn.bounds.size.height / 2) + 20 + (captureBtn.bounds.size.height / 2));
            
            // offset from capturebtn is '20'
            flashBtn.center = CGPointMake(centerX, captureBtn.center.y + (captureBtn.bounds.size.height / 2) + 20 + (flashBtn.bounds.size.height / 2));
            
            // offset from flashBtn is '20'
            switchCameraBtn.center = CGPointMake(centerX, flashBtn.center.y + (flashBtn.bounds.size.height / 2) + 20 + (switchCameraBtn.bounds.size.height / 2));
        }
        
        // just so it's ready when we need it to be.
        saveBtn.frame = switchCameraBtn.frame;
        
        if (!_capturedImageV.image) {
            for (UIButton * btn in @[backBtn, captureBtn, flashBtn, switchCameraBtn]) btn.hidden = NO;
            
            saveBtn.hidden = YES;
            
        }
        
        else {
            captureBtn.hidden = YES;
            flashBtn.hidden = YES;
            switchCameraBtn.hidden = YES;
            
            saveBtn.hidden = NO;
        }
        
        if (!_myDevice.isFlashAvailable) {
            flashBtn.alpha = .2;
            [flashBtn setTintColor:[self darkGreyColor]];
        }
        else {
            flashBtn.alpha = .6;
            
            if (_myDevice.isFlashActive) {
                [flashBtn setTintColor:[self greenColor]];
            }
            else {
                [flashBtn setTintColor:[self redColor]];
            }
        }
        
    } completion:nil];
}

#pragma mark BUTTON EVENTS

- (void) captureBtnPressed:(id)sender {
    isCapturingImage = YES;
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         
         UIImage * capturedImage = [[UIImage alloc]initWithData:imageData scale:1];
         
         if (_myDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0]) {
             // rear camera active
             if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
                 CGImageRef cgRef = capturedImage.CGImage;
                 capturedImage = [[UIImage alloc] initWithCGImage:cgRef scale:1.0 orientation:UIImageOrientationUp];
             }
             else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                 CGImageRef cgRef = capturedImage.CGImage;
                 capturedImage = [[UIImage alloc] initWithCGImage:cgRef scale:1.0 orientation:UIImageOrientationDown];
             }
         }
         else if (_myDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1]) {
             // front camera active
             
             // flip to look the same as the camera
             if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) capturedImage = [UIImage imageWithCGImage:capturedImage.CGImage scale:capturedImage.scale orientation:UIImageOrientationLeftMirrored];
             else {
                 if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
                     capturedImage = [UIImage imageWithCGImage:capturedImage.CGImage scale:capturedImage.scale orientation:UIImageOrientationDownMirrored];
                 else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
                     capturedImage = [UIImage imageWithCGImage:capturedImage.CGImage scale:capturedImage.scale orientation:UIImageOrientationUpMirrored];
             }
             
         }
         
         isCapturingImage = NO;
         _capturedImageV.image = capturedImage;
         imageData = nil;
         
         [self drawControls];
         
     }];
}

- (void) flashBtnPressed:(id)sender {
    if ([_myDevice isFlashAvailable]) {
        if (_myDevice.flashActive) {
            if([_myDevice lockForConfiguration:nil]) {
                _myDevice.flashMode = AVCaptureFlashModeOff;
                [flashBtn setTintColor:[self redColor]];
            }
        }
        else {
            if([_myDevice lockForConfiguration:nil]) {
                _myDevice.flashMode = AVCaptureFlashModeOn;
                [flashBtn setTintColor:[self greenColor]];
            }
        }
        [_myDevice unlockForConfiguration];
    }
}

- (void) backBtnPressed:(id)sender {
    if (_capturedImageV.image) {
        _capturedImageV.contentMode = UIViewContentModeScaleAspectFill;
        _capturedImageV.backgroundColor = [UIColor clearColor];
        _capturedImageV.image = nil;
        
        isRotateWaitingForResizedImage = NO;
        isImageResized = NO;
        isSaveWaitingForResizedImage = NO;
        
        [previewCoverLayer removeFromSuperlayer];
        previewCoverLayer = nil;
        
        [self drawControls];
    }
    else {
        [self close];
    }
}

- (void) switchCameraBtnPressed:(id)sender {
    if (isCapturingImage != YES) {
        if (_myDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0]) {
            // rear active, switch to front
            _myDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1];
            
            [_mySesh beginConfiguration];
            AVCaptureDeviceInput * newInput = [AVCaptureDeviceInput deviceInputWithDevice:_myDevice error:nil];
            for (AVCaptureInput * oldInput in _mySesh.inputs) {
                [_mySesh removeInput:oldInput];
            }
            [_mySesh addInput:newInput];
            [_mySesh commitConfiguration];
        }
        else if (_myDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1]) {
            // front active, switch to rear
            _myDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0];
            [_mySesh beginConfiguration];
            AVCaptureDeviceInput * newInput = [AVCaptureDeviceInput deviceInputWithDevice:_myDevice error:nil];
            for (AVCaptureInput * oldInput in _mySesh.inputs) {
                [_mySesh removeInput:oldInput];
            }
            [_mySesh addInput:newInput];
            [_mySesh commitConfiguration];
        }
        
        if (!_myDevice.isFlashAvailable) {
            flashBtn.alpha = .2;
            [flashBtn setTintColor:[self darkGreyColor]];
        }
        else {
            flashBtn.alpha = .6;
            
            if (_myDevice.isFlashActive) {
                [flashBtn setTintColor:[self greenColor]];
            }
            else {
                [flashBtn setTintColor:[self redColor]];
            }
        }
    }
}

- (void) saveBtnPressed:(id)sender {
    if (isImageResized) {
        [self close];
    }
    else {
        isSaveWaitingForResizedImage = YES;
        [self resizeImage];
    }
}

#pragma mark TAP TO FOCUS

- (void) tapSent:(UITapGestureRecognizer *)sender {
    
    if (_capturedImageV.image == nil) {
        CGPoint aPoint = [sender locationInView:_imageStreamV];
        if (_myDevice != nil) {
            if([_myDevice isFocusPointOfInterestSupported] &&
               [_myDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                
                // we subtract the point from the width to inverse the focal point
                // focus points of interest represents a CGPoint where
                // {0,0} corresponds to the top left of the picture area, and
                // {1,1} corresponds to the bottom right in landscape mode with the home button on the right—
                // THIS APPLIES EVEN IF THE DEVICE IS IN PORTRAIT MODE
                // (from docs)
                // this is all a touch wonky
                double pX = aPoint.x / _imageStreamV.bounds.size.width;
                double pY = aPoint.y / _imageStreamV.bounds.size.height;
                double focus_x = pY;
                // x is equal to y but y is equal to inverse x ?
                double focus_y = 1 - pX;
                
                //NSLog(@"SC: about to focus at x: %f, y: %f", focus_x, focus_y);
                if([_myDevice isFocusPointOfInterestSupported] && [_myDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                    
                    if([_myDevice lockForConfiguration:nil]) {
                        [_myDevice setFocusPointOfInterest:CGPointMake(focus_x, focus_y)];
                        [_myDevice setFocusMode:AVCaptureFocusModeAutoFocus];
                        [_myDevice setExposurePointOfInterest:CGPointMake(focus_x, focus_y)];
                        [_myDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                        //NSLog(@"SC: Done Focusing");
                    }
                    [_myDevice unlockForConfiguration];
                }
            }
        }
    }
}

#pragma mark RESIZE IMAGE

- (void) resizeImage {
    
    CGSize size = CGSizeMake(screenWidth, screenHeight);
    BOOL isLandscape = NO;
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        size = CGSizeMake(screenHeight, screenWidth);
        isLandscape = YES;
    }
    
    if (_isSquareMode) size = squareV.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(size, YES, 2.0);
    
    // the width necessary to maintain aspect ratio at current screenHeight
    if (!isLandscape) {
        // IS CURRENTLY PORTRAIT
        
        
        // targetWidth is the width our image would need to be at the current screenheight if we maintained the image ratio.
        CGFloat targetWidth = screenHeight * 0.75; // 3:4 ratio
        
        
        // we have to draw around the context of the screen
        // our final image will be the image that is left in the frame of the context
        // by drawing outside it, we remove the edges of the picture
        CGFloat offsetTop = (screenHeight - size.height) / 2;
        CGFloat offsetLeft = (targetWidth - size.width) / 2;
        
        [_capturedImageV.image drawInRect:CGRectMake(-offsetLeft, -offsetTop, targetWidth, screenHeight)];
    }
    else {
        
        CGFloat targetHeight = screenHeight * 0.75; // 3:4 ratio
        // targetHeight is the height our image would need to be at the current screenwidth (height in portrait) if we maintained the image ratio.
        
        
        
        CGFloat offsetTop = (targetHeight - size.height) / 2;
        // screenheight is width in landscape
        CGFloat offsetLeft = (screenHeight - size.width) / 2;
        
        [_capturedImageV.image drawInRect:CGRectMake(-offsetLeft, -offsetTop, screenHeight, targetHeight)];
    }
    
    _capturedImageV.image = nil; // helps with a memory spike
    _capturedImageV.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    
    if (isSaveWaitingForResizedImage == YES) {
        [self close];
    }
    if (isRotateWaitingForResizedImage == YES) _capturedImageV.contentMode = UIViewContentModeScaleAspectFit;
    isImageResized = YES;
}

#pragma mark ROTATION

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    CGRect targetSize;
    
    if (_capturedImageV.image) {
        _capturedImageV.backgroundColor = [UIColor blackColor];
        
        // adding cover layer bc otherwise you see a glint of the camera when rotating and it looks weird.
        // you could stop the stream, but it takes a sec to get it started again.
        if (previewCoverLayer == nil) {
            previewCoverLayer = [[CALayer alloc]init];
            previewCoverLayer.backgroundColor = [UIColor blackColor].CGColor;
            previewCoverLayer.bounds = CGRectMake(0, 0, screenHeight * 3, screenHeight * 3); // 1 full screen size either direction
            previewCoverLayer.anchorPoint = CGPointMake(0.5, 0.5);
            _imageStreamV.layer.masksToBounds = NO;
            [_imageStreamV.layer addSublayer:previewCoverLayer];
        }
        
        if (!isImageResized) {
            isRotateWaitingForResizedImage = YES;
            [self resizeImage];
        }
    }
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        targetSize = CGRectMake(0, 0, screenHeight, screenWidth);
        
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
            _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }
        else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
        
    }
    else
    {
        targetSize = CGRectMake(0, 0, screenWidth, screenHeight);
        
        _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        for (UIView * v in @[_capturedImageV, _imageStreamV, self.view]) {
            v.frame = targetSize;
        }
        
        // not in for statement, cuz layers
        _captureVideoPreviewLayer.frame = _imageStreamV.bounds;
        
    } completion:^(BOOL finished) {
        [self drawControls];
    }];
    
}

#pragma mark CLOSE

- (void) close {
    [self dismissViewControllerAnimated:YES completion:^{
        
        [_delegate closeSimpleCam:self withImage:_capturedImageV.image];
        
        // CLEAN UP
        lighteningImg = nil;
        downloadImg = nil;
        previousImg = nil;
        cameraRotateImg = nil;
        
        [previewCoverLayer removeFromSuperlayer];
        previewCoverLayer = nil;
        
        isRotateWaitingForResizedImage = NO;
        isImageResized = NO;
        isSaveWaitingForResizedImage = NO;
        
        _capturedImageV.image = nil;
        [_capturedImageV removeFromSuperview];
        _capturedImageV = nil;
        
        [_imageStreamV removeFromSuperview];
        _imageStreamV = nil;
        
        
        [_mySesh stopRunning];
        _mySesh = nil;
        
        _stillImageOutput = nil;
        _myDevice = nil;
        
        self.view = nil;
        _delegate = nil;
        [self removeFromParentViewController];
        
    }];
    
}

#pragma mark COLORS

- (UIColor *) darkGreyColor {
    return [UIColor colorWithRed:0.226082 green:0.244034 blue:0.297891 alpha:1];
}
- (UIColor *) redColor {
    return [UIColor colorWithRed:1 green:0 blue:0.105670 alpha:.6];
}
- (UIColor *) greenColor {
    return [UIColor colorWithRed:0.128085 green:.749103 blue:0.004684 alpha:0.6];
}
- (UIColor *) blueColor {
    return [UIColor colorWithRed:0 green:.478431 blue:1 alpha:1];
}

#pragma mark STATUS BAR

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
