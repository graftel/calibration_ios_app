# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'Graftel' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Graftel
  pod 'AWSS3'
  pod 'Zip', '~> 0.6'
  pod 'SendGrid', :git => 'https://github.com/scottkawai/sendgrid-swift.git'
  pod 'CryptoSwift', :git => "https://github.com/krzyzanowskim/CryptoSwift", :branch => "master"
  target 'GraftelTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'GraftelUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
