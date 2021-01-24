#
# Be sure to run `pod lib lint PrayerIDN.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PrayerIDN'
  s.version          = '1.1.3'
  s.summary          = 'PrayerIDN is SDK swift prayer time and Al-Quran for Indonesia only.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  PrayerIDN is SDK swift prayer time specially Indonesia only.
  
  Get Started with one line
  ```let prayer = PrayerIDN(coordinate: PrayerIDN.Coordinate(latitude: 102.313718, longitude: -57.318388), date: DateComponents)```
  
  you can get times
  ```prayer.times```
  
  delegate into ```PrayerDelegate``` to get updateTimes whiles your device update locations
                       DESC

  s.homepage         = 'https://github.com/ranggaleoo/PrayerIDN'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ranggaleoo' => 'leorangga30@ymail.com' }
  s.source           = { :git => 'https://github.com/ranggaleoo/PrayerIDN.git', :tag => s.version.to_s }
  s.social_media_url = 'https://instagram.com/ranggaleoo'
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.swift_versions = '5.0'

  s.source_files = 'PrayerIDN/Src/**/*'
  
  # s.resource_bundles = {
  #   'PrayerIDN' => ['PrayerIDN/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
