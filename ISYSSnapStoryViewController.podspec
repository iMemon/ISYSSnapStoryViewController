#
# Be sure to run `pod lib lint ISYSSnapStoryViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ISYSSnapStoryViewController'
  s.version          = '0.1.0'
  s.summary = 'A subclass on UILabel that provides a blink.'
  s.description= 'This CocoaPod provides the ability to use a UILabel that may be started and stopped blinking.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.homepage         = 'https://github.com/iMemon/ISYSSnapStoryViewController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'iMemon' => 'ayazahmed313@gmail.com' }
  s.source           = { :git => 'https://github.com/iMemon/ISYSSnapStoryViewController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/ayazahmed313'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ISYSSnapStoryViewController/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ISYSSnapStoryViewController' => ['ISYSSnapStoryViewController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'VIMediaCache', '~> 0.1'
  s.dependency 'SpinKit', '~> 1.2'
  # s.dependency 'SnapTimer'
end
