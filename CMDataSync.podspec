#
# Be sure to run `pod lib lint CMDataSync.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CMDataSync'
  s.version          = '0.1.0'
  s.summary          = 'CMDataSync SDK provides easy way to implement file transfer function in app.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'http://cmic.tools.bigcloudsys.cn/gitlab/mail/iOS/CMDataSync.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'panshaosen' => '19802021493@139.com' }
  s.source           = { :git => 'http://cmic.tools.bigcloudsys.cn/gitlab/mail/iOS/CMDataSync.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.public_header_files = 'Classes/**/*.h'
  s.source_files = 'Classes/**/*.{h,m}'
  
  # s.resource_bundles = {
  #   'CMDataSync' => ['CMDataSync/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'CocoaAsyncSocket'
   
end
