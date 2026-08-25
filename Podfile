# Uncomment the next line to define a global platform for your project
platform :ios, '17.0'

target 'MSA' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MSA
  
  pod 'Alamofire', '~> 5.10.2'
  pod 'NVActivityIndicatorView'
  
  # Firebase
  pod 'Firebase/Firestore'
  pod 'Firebase/Messaging'
  pod 'Firebase/Crashlytics'
  pod 'FirebaseAnalytics'
pod 'ImageSlideshow'
pod 'Firebase/Auth'
 pod 'LightweightCharts'

pod 'DGCharts'
 
  pod 'Socket.IO-Client-Swift', '~> 16.1.0'
  pod 'AJMessage'
  pod 'Cosmos', '~> 16.0'
  pod 'Kingfisher', '~> 7.10.0'
  pod 'IQKeyboardManagerSwift'
 
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      if target.name == 'BoringSSL-GRPC'
        target.source_build_phase.files.each do |file|
          if file.settings && file.settings['COMPILER_FLAGS']
            flags = file.settings['COMPILER_FLAGS'].split
            flags.reject! { |flag| flag == '-G' }
            file.settings['COMPILER_FLAGS'] = flags.join(' ')
          end
        end
      end
    end
  end
end
