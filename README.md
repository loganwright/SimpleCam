<h1 align="center">SimpleCam</h1>

<h4 align="center">A Memory Efficient Drop In Replacement / Alternative for the Native UIImagePicker Camera</h4>

<p align="center">
  <img src="https://github.com/LoganWright/SimpleCam/blob/master/SimpleCam/Images/SimpleCamCover.png?raw=true" width=320></img> 
</p>

<h3>Why Do I Need It?</h3>

SimpleCam was created out of the necessity to have high quality photographs while providing a lightweight memory footprint.  Apple's UIImagePicker is a wonderful application, but because it has a lot of features and a lot of options, . . . it uses a lot of MEMORY.  This can cause crashes, lag, and an overall poor experience when all you wanted was to give the user an opportunity to take a quick picture.

If you're capturing photographs with UIImagePicker, or via AVFoundation on the highest possible capture resolution, it will return giant image files exceeding thousands of pixels in size.  SimpleCam avoids this while still using the highest possible capture resolution by resizing the photo to 2x the size of the phone's screen.  This allows the photo to maintain a significantly reduced file size while still looking clean and brilliant on mobile displays.

I hope you find the project as useful as I did!

<h3>Features</h3>
<ul>
  <li>iOS 7 Inspired Design</li>
  <li>3.5” & 4” Screen Compatibility</li>
  <li>Low Memory Usage</li>
  <li>Drag & Drop Installation</li> 
  <li>Portrait/Landscape Views</li> 
  <li>Front/Rear Camera</li> 
  <li>Touch to Focus</li> 
  <li>Controllable Flash</li>
  <li>Auto Crop / Scale</li>
  <li>Selfies Don't Flip</li>
</ul>

<p align="center">
  <img src="https://github.com/LoganWright/SimpleCam/blob/master/SimpleCam/Images/placeit.png?raw=true" width=860></img> 
</p>

<p>
Icon's generously provided by PixelLove:
</p>
<p>
<a href="http://pixellove.com" target="_blank"> 
  <img src="https://github.com/LoganWright/SimpleCam/blob/master/SimpleCam/Images/Attribution_PixelLove.png?raw=true" width=200></img>
</a> 
</p>

#Adding SimpleCam to Your Project

###1. Add SimpleCam Folder to Xcode

- Unzip SimpleCam
- Drag SimpleCam Folder into your Xcode project
- Make sure "Copy items into destination group's folder (if needed)" is selected

###2. Your ViewController.h File

- Import SimpleCam
- Set up your view controller as a SimpleCam delegate

```Obj-C
#import <UIKit/UIKit.h>
#import "SimpleCam.h"

@interface ViewController : UIViewController <SimpleCamDelegate>

@end
```

###3. Set Up Delegate

- Add SimpleCam's Delegate method to your ViewController.m file
- Close SimpleCam

This is how SimpleCam will notify your ViewController that the user is finished with it.  If there is an image, then the user took a picture.  If there is not, then the user backed out of the camera without taking a photograph.  Make sure to close SimpleCam in this method using SimpleCam's custom close.  Otherwise, the captureSession may not close properly and may result in memory leaks.

```Obj-C
#pragma mark SIMPLE CAM DELEGATE

- (void) simpleCam:(SimpleCam *)simpleCam didFinishWithImage:(UIImage *)image {
    
    if (image) {
        // simple cam finished with image
    }
    else {
        // simple cam finished w/o image
    }
    
    // Close simpleCam - use this as opposed to dismissViewController: to properly end photo session
    [simpleCam closeWithCompletion:^{
        NSLog(@"SimpleCam is done closing ... ");
        // It is safe to launch other ViewControllers, for instance, an editor here.
    }];
}
```

###4. Launch SimpleCam

- Add this code wherever you'd like SimpleCam to launch

```Obj-C
SimpleCam * simpleCam = [[SimpleCam alloc]init];
simpleCam.delegate = self;    
[self presentViewController:simpleCam animated:YES completion:nil];
```
If you'd like to launch simple cam when the user presses a button, you could add the above code to the buttonPress method, like so:

```Obj-C
- (void) buttonPress:(id)sender {        
  SimpleCam * simpleCam = [[SimpleCam alloc]init];
  simpleCam.delegate = self;    
  [self presentViewController:simpleCam animated:YES completion:nil];
}
```
That's it, it's as  simple as that.  SimpleCam will take care of everything else!

#ChangeLog

v1.01 Released 19 May 2014

Thanks @capezzbr & @dkhamsing for their contributions to this commit!

- You can now capture photos programmatically by calling `[simpleCam capturePhoto]`
- Now supports an overlay control system (more interaction possibilities coming soon!)
- Disable Photo Preview to save photos as soon as they're captured: `simpleCam.disablePhotoPreview = YES`
- New delegate method to be notified of when the camera stream is visible:

```ObjC
- (void) simpleCamDidLoadCameraIntoView:(SimpleCam *)simpleCam {
    NSLog(@"Camera loaded ... ");
}
```

#Screen Shots

###Portrait
<h5 align="center">Camera (About To Capture)</h5>
<p align="center">
  <img src="https://github.com/LoganWright/SimpleCam/blob/master/SimpleCam/Images/portrait_Camera.png?raw=true" width=320></img> 
</p>

<h5 align="center">Preview (Shows Captured Image)</h5>
<p align="center">
  <img src="https://github.com/LoganWright/SimpleCam/blob/master/SimpleCam/Images/portrait_Preview.png?raw=true" width=320></img> 
</p>

<h5 align="center">Preview - Rotated (Maintains Captured Image Ratio)</h5>
<p align="center">
  <img src="https://github.com/LoganWright/SimpleCam/blob/master/SimpleCam/Images/portrait_RotatedPreview.png?raw=true" width=568></img> 
</p>


###Landscape

<h5 align="center">Camera (About To Capture)</h5>
<p align="center">
  <img src="https://github.com/LoganWright/SimpleCam/blob/master/SimpleCam/Images/landscape_Camera.png?raw=true" width=568></img> 
</p>

<h5 align="center">Preview (Shows Captured Image)</h5>
<p align="center">
  <img src="https://github.com/LoganWright/SimpleCam/blob/master/SimpleCam/Images/landscape_Preview.png?raw=true" width=568></img> 
</p>

<h5 align="center">Preview - Rotated (Maintains Captured Image Ratio)</h5>
<p align="center">
  <img src="https://github.com/LoganWright/SimpleCam/blob/master/SimpleCam/Images/landscape_RotatedPreview.png?raw=true" width=320></img> 
</p>
