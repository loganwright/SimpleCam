//
//  RootViewController.m
//  SimpleCam
//
//  Created by Logan Wright on 3/31/14.
//  Copyright (c) 2014 Logan Wright. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController () <UIActionSheetDelegate>

@property (strong, nonatomic) UIImageView * imgView;
@property (strong, nonatomic) UILabel * tapLabel;
@property (nonatomic,strong) SimpleCam *simpleCam;
@property (nonatomic) BOOL takePhotoImmediately;

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _imgView = [UIImageView new];
    _imgView.bounds = CGRectMake(0, 0, 200, 300);
    _imgView.center = self.view.center;
    _imgView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imgView];
    
    _tapLabel = [UILabel new];
    _tapLabel.bounds = CGRectMake(0, 0, 200, 100);
    _tapLabel.text = @"TAP TO TAKE PHOTO";
    _tapLabel.textAlignment = NSTextAlignmentCenter;
    _tapLabel.center = self.view.center;
    _tapLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:_tapLabel];
    
    UITapGestureRecognizer * tap = [UITapGestureRecognizer new];
    [tap addTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
}

#pragma mark ACTIONSHEET

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    self.takePhotoImmediately = NO;
    switch (buttonIndex) {
        case 0: // default
        {
            SimpleCam * simpleCam = [SimpleCam new];
            simpleCam.delegate= self;
            
            [self presentViewController:simpleCam animated:YES completion:nil];
        }
            break;
            
        case 1: // take photo immediately
        {
            self.takePhotoImmediately = YES;
            
            SimpleCam * simpleCam = [SimpleCam new];
            simpleCam.delegate= self;
            // [simpleCam setHideCaptureButton:YES];
            // [simpleCam setHideBackButton:YES];
            simpleCam.hideAllControls = YES;
            [simpleCam setDisablePhotoPreview:YES];
            [self presentViewController:simpleCam animated:YES completion:nil];
        }
            break;
            
        case 2: // overlay
        {
            self.simpleCam = [SimpleCam new];
            self.simpleCam.delegate= self;
            [self.simpleCam setHideAllControls:YES];
            [self.simpleCam setDisablePhotoPreview:YES];
            
            CGRect frame;
            frame.size = CGSizeMake(self.view.frame.size.width, 120);
            frame.origin.x = 0;
            frame.origin.y = self.view.frame.size.height -frame.size.height;
            UIView *overlayView = [[UIView alloc] initWithFrame:frame];
            overlayView.backgroundColor = [UIColor blackColor];
            overlayView.alpha = 0.3;
            overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            
            UIImage *image = [UIImage imageNamed:@"shutter"];
            frame.size = image.size;
            frame.origin.x = (overlayView.frame.size.width -frame.size.width)/2;
            frame.origin.y = (overlayView.frame.size.height -frame.size.height)/2;
            UIButton *button = [[UIButton alloc] initWithFrame:frame];
            [button setImage:image forState:UIControlStateNormal];
            [button addTarget:self action:@selector(actionPhoto) forControlEvents:UIControlEventTouchUpInside];
            button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            [overlayView addSubview:button];
            [self.simpleCam.view addSubview:overlayView];
            
            [self presentViewController:self.simpleCam animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark PRIVATE

- (void)actionPhoto
{
    [self.simpleCam  capturePhoto];
}

#pragma mark TAP RECOGNIZER

- (void) handleTap:(UITapGestureRecognizer *)tap {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"SimpleCam Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Default", @"Take Photo Immediately", @"Custom", nil];
    [sheet showInView:self.view];
    
    
}

#pragma mark SIMPLE CAM DELEGATE

- (void) simpleCam:(SimpleCam *)simpleCam didFinishWithImage:(UIImage *)image {
    
    if (image) {
        // simple cam finished with image
        
        _imgView.image = image;
        //_tapLabel.hidden = NO;
    }
    else {
        // simple cam finished w/o image
        
        _imgView.image = nil;
        //_tapLabel.hidden = NO;
    }
    
    // Close simpleCam - use this as opposed to 'dismissViewController' otherwise, the captureSession may not close properly and may result in memory leaks.
    [simpleCam closeWithCompletion:^{
        NSLog(@"SimpleCam is done closing ... ");
    }];
}

- (void) simpleCamDidLoadCameraIntoView:(SimpleCam *)simpleCam {
    NSLog(@"Camera loaded ... ");
    
    if (self.takePhotoImmediately) {
        [simpleCam capturePhoto];
    }
}

- (void) simpleCamNotAuthorizedForCameraUse:(SimpleCam *)simpleCam {
    [simpleCam closeWithCompletion:^{
        NSLog(@"SimpleCam is done closing ... Not Authorized");
    }];
}

@end
