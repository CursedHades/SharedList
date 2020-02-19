# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'SharedList' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    # use_frameworks!
    use_modular_headers!

    # Pods for SharedList
    pod 'Firebase'
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'SVProgressHUD'
#   pod 'ChameleonFramework'
    pod 'MulticastDelegateSwift'
    pod 'PopupDialog', '~> 0.9'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
        end
    end
end
