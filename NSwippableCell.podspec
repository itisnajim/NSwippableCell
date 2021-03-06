#
# Be sure to run `pod lib lint NSwippableCell.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NSwippableCell'
  s.version          = '0.2.0'
  s.summary          = 'An easy-to-use UICollectionViewCell subclass that implements a swipeable content view which exposes utility buttons or views'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  An easy-to-use UICollectionViewCell subclass that implements a swipeable content view which exposes utility buttons or views
                       DESC

  s.homepage         = 'https://github.com/itisnajim/NSwippableCell'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'itisnajim' => 'itisnajim@gmail.com' }
  s.source           = { :git => 'https://github.com/itisnajim/NSwippableCell.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ItisNajim'

  s.ios.deployment_target = '9.0'

  s.source_files = 'NSwippableCell/Classes/**/*'
  
  # s.resource_bundles = {
  #   'NSwippableCell' => ['NSwippableCell/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
