#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint dp3t.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'dp3t'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/pgte/flutter-dp3t'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Pedro Teixeira' => 'i@pgte.me' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'

  # Other dependencies
  s.dependency 'DP3TSDK', '~> 0.0.2'
end
