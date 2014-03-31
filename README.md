<h1 align="center">SimpleCam</h1>

<h4 align="center">A Memory Efficient Drop In Camera Replacement / Alternative for UIImagePicker</h4>

<h3>Why Do I Need It?</h3>

SimpleCam was created out of the necessity to have high quality photographs while providing a lightweight memory footprint.  Apple's UIImagePicker is a wonderful application, but because it has a lot of features and a lot of options, . . . it uses a lot of MEMORY.  This can cause crashes, lag, and an overall poor user experience when all you wanted was to give the user an opportunity to take a quick picture.

If you're capturing photographs with UIImagePicker, or via AVFoundation on the highest possible capture resolution, it will return giant image files exceeding thousands of pixels in size.  SimpleCam avoids this while still using the highest possible capture resolution by resizing the photo to 2x the size of the phone's screen.  This allows the photo to maintain a significantly reduced file size while still looking clean and brilliant on mobile displays.

I hope you find the project as useful as I did, and I'll continue to add more features including more customization options. 

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

#Adding SimpleCam to Your Project

###1. Add SimpleCam Folder to Xcode

- Unzip SimpleCam
- Drag SimpleCam Folder into your Xcode project
- Make sure "Copy items into destination group's folder (if needed)" is selected

###2. Your ViewController.h File

- Import SimpleCam
- Set up your view controller as a simpleCam delegate

```Obj-C
#import <UIKit/UIKit.h>
#import "SimpleCam.h"

@interface ViewController : UIViewController <SimpleCamDelegate>

@end
```

###3. Set Up Delegate

- Add SimpleCam's Delegate method to your ViewController.m file

```Obj-C
#pragma mark SIMPLE CAM DELEGATE

- (void) closeSimpleCamWithImage:(UIImage *)image {
    if (image) {
        // closed with image
    }
    else {
        // user backed out w/o image
    }
}
```

This is how SimpleCam will notify your ViewController that the user is finished with it.  If there is an image, then the user took a picture.  If there is not, then the user backed out of the camera without taking a photograph.

###4. Launch SimpleCam

- Add this code wherever you'd like SimpleCam to launch

```Obj-C
SimpleCam * simpleCam = [[SimpleCam alloc]init];
simpleCam.delegate = self;    
[self presentViewController:simpleCam animated:YES completion:nil];
```
If you'd like to launch simple cam when the user presses a button, you could add the above code to the IBAction method, like so:

```Obj-C
-(IBAction)buttonPress:(id)sender
{        
  SimpleCam * simpleCam = [[SimpleCam alloc]init];
  simpleCam.delegate = self;    
  [self presentViewController:simpleCam animated:YES completion:nil];
}
```
That's it, it's as  simple as that.  SimpleCam will take care of everything else.

#Screen Shots

###Portrait
<h5 align="center">Camera (About To Capture)</h5>
<p align="center">
  <img src="https://github.com/LoganWright/SimpleCam/blob/master/SimpleCam/portrait_Camera.png?raw=true" width=320></img> 
</p>

<h5 align="center">Preview (Shows Captured Image)</h5>
<p align="center">
  <img src="https://github.com/LoganWright/SimpleCam/blob/master/SimpleCam/portrait_Preview.png?raw=true" width=320></img> 
</p>

<h5 align="center">Preview - Rotated (Maintains Captured Image Ratio)</h5>
<p align="center">
  <img src="https://github.com/LoganWright/SimpleCam/blob/master/SimpleCam/portrait_RotatedPreview.png?raw=true" width=568></img> 
</p>


###Landscape

<h5 align="center">Camera (About To Capture)</h5>
<p align="center">
  <img src="https://github.com/LoganWright/SimpleCam/blob/master/SimpleCam/landscape_Camera.png?raw=true" width=568></img> 
</p>

<h5 align="center">Preview (Shows Captured Image)</h5>
<p align="center">
  <img src="https://github.com/LoganWright/SimpleCam/blob/master/SimpleCam/landscape_Preview.png?raw=true" width=568></img> 
</p>

<h5 align="center">Preview - Rotated (Maintains Captured Image Ratio)</h5>
<p align="center">
  <img src="https://github.com/LoganWright/SimpleCam/blob/master/SimpleCam/landscape_RotatedPreview.png?raw=true" width=320></img> 
</p>
