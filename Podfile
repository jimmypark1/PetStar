# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'PetStarGram' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  
  pod 'GPUImage'
  pod 'AFNetworking', '~> 3.0'
  pod 'SSZipArchive'
  pod 'SDWebImage', '~> 4.0'
  pod 'MBProgressHUD'
  pod 'SwiftyStoreKit'
  pod 'Firebase/Messaging'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'Google-Mobile-Ads-SDK'
  pod 'MPSkewed'
  pod 'Harpy'
  pod 'Onboard'
  pod 'ZWIntroductionViewController'
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'
  pod 'SwiftKeychainWrapper'
  pod 'TRMosaicLayout'
  pod 'PINRemoteImage'
  pod 'GoogleSignIn'
  pod 'MaterialComponents'
  pod 'PinterestSegment'
  pod 'FirebaseUI/Auth'
  pod 'FirebaseUI/Facebook'
  pod 'FirebaseUI/Google'
  pod 'ESTabBarController-swift'
  pod 'pop', '~> 1.0'
  pod 'RSLoadingView'
  pod 'JSQMessagesViewController'
  pod 'NVActivityIndicatorView'
  pod 'MBCircularProgressBar'
  pod 'EAIntroView'
  pod 'Presentation'
  pod 'Hue'
  pod 'Segmentio', '~> 3.0'
  pod 'Hero'
  pod 'Segmentio', '~> 3.0'
  pod 'Pages'
  pod 'SnapKit'
  pod 'SwiftyJSON'
  pod 'DLRadioButton'
  pod "TTGSnackbar"
#  pod 'FirebaseAnalytics', '~> 9.6.0'

 post_install do |installer|
   installer.pods_project.targets.each do |target|
     target.build_configurations.each do |config|
       config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
       config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0' # 원하는 최소 버전
     end
   end
 end
end
