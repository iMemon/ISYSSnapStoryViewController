#
# Be sure to run `pod lib lint ISYSSnapStoryViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ISYSSnapStoryViewController'
  s.version          = '0.2'
  s.summary = 'Snapchat inspired Story player with video caching, next, back etc.'
  s.description= 'Snapchat inspired Story player with video caching, next, back etc.'

  s.homepage         = 'https://github.com/iMemon/ISYSSnapStoryViewController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'iMemon' => 'ayazahmed313@gmail.com' }
  s.source           = { :git => 'https://github.com/iMemon/ISYSSnapStoryViewController.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ayazahmed313'

  s.ios.deployment_target = '9.0'

  s.source_files = 'ISYSSnapStoryViewController/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ISYSSnapStoryViewController' => ['ISYSSnapStoryViewController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation', 'AVFoundation'
  s.dependency "SpinKit", "~> 1.2"
  s.dependency 'TWRDownloadManager', '~> 1.1'
end
