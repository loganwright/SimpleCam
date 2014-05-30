#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "SimpleCam"
  s.version          = "0.1.0"
  s.summary          = "A Memory Efficient Drop In Replacement / Alternative for the Native UIImagePicker Camera"
  s.description      = "SimpleCam was created out of the necessity to have high quality photographs while providing a lightweight memory footprint. Apple's UIImagePicker is a wonderful application, but because it has a lot of features and a lot of options, . . . it uses a lot of MEMORY. This can cause crashes, lag, and an overall poor experience when all you wanted was to give the user an opportunity to take a quick picture.

If you're capturing photographs with UIImagePicker, or via AVFoundation on the highest possible capture resolution, it will return giant image files exceeding thousands of pixels in size. SimpleCam avoids this while still using the highest possible capture resolution by resizing the photo to 2x the size of the phone's screen. This allows the photo to maintain a significantly reduced file size while still looking clean and brilliant on mobile displays.

I hope you find the project as useful as I did!"
  s.homepage         = "http://github.com/LoganWright"
  s.screenshots      = "https://github.com/LoganWright/SimpleCam/blob/master/SimpleCam/Images/SimpleCamCover.png?raw=true"
  s.license          = {:type => 'MPL 2.0'}
  s.author           = { "Logan Wright" => "logan.william.wright@gmail.com" }
  s.source           = { :git => "https://github.com/LoganWright/SimpleCam.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/logmaestro'

  s.platform     = :ios, '5.0'
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true

  s.source_files = 'SimpleCam/SimpleCam
  /SimpleCam.h', 'SimpleCam/SimpleCam/SimpleCam.m'
  s.resources = 'SimpleCam/SimpleCam/Icons/*.png'

  # s.ios.exclude_files = 'Classes/osx'
  # s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  # s.frameworks = 'SomeFramework', 'AnotherFramework'
  # s.dependency 'JSONKit', '~> 1.4'
end
