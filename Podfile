# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'ClickBye' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings! 

  # Pods for ClickBye
	pod 'NHRangeSlider', '~> 0.2'
	pod 'M13Checkbox'
	pod 'GoogleMaps', '~> 2.1'
	pod 'GooglePlaces', '~> 2.1'
	pod 'Material', '~> 2.0'
	pod 'PageMenu', :git => 'https://github.com/orazz/PageMenu.git'
	pod 'DropDown'
	pod 'SideMenu'
	pod 'Alamofire', '~> 4.2'
	pod 'SwiftyJSON', '~> 3.1'
    pod 'MaterialControls', :path => 'LocalPods/MaterialControls'
	pod "KCFloatingActionButton", "~> 2.1.0"
	pod 'SDWebImage', '~>3.8'
	pod 'JTMaterialSpinner', '~> 2.0'
	pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
    pod 'SVProgressHUD'
    pod 'FlickrKit'
    pod 'TPKeyboardAvoiding'
    pod 'CryptoSwift'
    pod 'ForecastIO'
    pod 'RNCryptor'
    pod 'AlamofireObjectMapper'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'Localize-Swift'
    pod 'TTRangeSlider'
    pod 'SnapKit'
    pod 'Analytics'
    pod 'EZYGradientView', :git => 'https://github.com/Niphery/EZYGradientView'
    pod 'KeychainAccess'
    pod 'Segment-Amplitude'
    pod 'Segment-Apptimize'
    pod 'Segment-Branch'
    pod 'Segment-Mixpanel'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'

        end
    end

end
