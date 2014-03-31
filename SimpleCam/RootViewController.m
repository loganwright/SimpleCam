//
//  RootViewController.m
//  SimpleCam
//
//  Created by Logan Wright on 3/31/14.
//  Copyright (c) 2014 Logan Wright. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@property (strong, nonatomic) UIImageView * imgView;
@property (strong, nonatomic) UILabel * tapLabel;

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
    
    _tapLabel = [UILabel new];
    _tapLabel.bounds = CGRectMake(0, 0, 200, 100);
    _tapLabel.text = @"** TAP TO OPEN **";
    _tapLabel.textAlignment = NSTextAlignmentCenter;
    _tapLabel.center = self.view.center;
    _tapLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:_tapLabel];
    
    UITapGestureRecognizer * tap = [UITapGestureRecognizer new];
    [tap addTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    
    _imgView = [UIImageView new];
    _imgView.bounds = CGRectMake(0, 0, 200, 300);
    _imgView.center = self.view.center;
    [self.view addSubview:_imgView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TAP RECOGNIZER

- (void) handleTap:(UITapGestureRecognizer *)tap {
    SimpleCam * simpleCam = [SimpleCam new];
    simpleCam.delegate= self;
    [self presentViewController:simpleCam animated:YES completion:nil];
}

#pragma mark SIMPLE CAM DELEGATE

- (void) closeSimpleCam:(SimpleCam *)simpleCam withImage:(UIImage *)image {
    if (image) {
        // simple cam closed with image
        
        _imgView.image = image;
        _tapLabel.hidden = YES;
    }
    else {
        // simple cam backed out w/o image
        
        _imgView.image = nil;
        _tapLabel.hidden = NO;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
