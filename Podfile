platform :ios, '14.0'

target 'VKPodcasts' do
  use_frameworks!
  pod "VK-ios-sdk"

  target 'VKPodcastsTests' do
    inherit! :search_paths
  end

  target 'VKPodcastsUITests' do
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end