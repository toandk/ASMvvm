#
# Be sure to run `pod lib lint ASMvvm.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ASMvvm'
  s.version          = '1.1.1'
  s.summary          = 'A MVVM library for iOS Swift, Wrapped TextureGroup (AsyncDisplayKit)'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A MVVM library for iOS Swift, including interfaces for View, ViewModel and Model, DI and Services
                       DESC

  s.homepage         = 'https://github.com/toandk/ASMvvm.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ToanDK' => 'dkt204@gmail.com' }
  s.source           = { :git => 'https://github.com/toandk/ASMvvm.git', :tag => s.version.to_s }
  s.swift_version    = '5.0'
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'ASMvvm/**/*'

  # s.resource_bundles = {
  #   'ASMvvm' => ['ASMvvm/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa-Texture', '~> 3.1.0'
  s.dependency 'RxSwift'
  s.dependency 'RxASDataSources'
  s.dependency 'ObjectMapper'
  s.dependency 'Texture', '~> 3.0.0'
#  s.dependency 'Texture/Yoga'
end
