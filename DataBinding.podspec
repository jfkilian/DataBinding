Pod::Spec.new do |s|
  s.name             = "DataBinding"
  s.version          = "1.0.0"
  s.summary          = "leightweight swifty data binding for iOS"
  s.homepage         = "https://github.com/jfkilian"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "jfkilian" => "mail@jkilian.de" }
  s.source           = { :git => "https://github.com/jfkilian/DataBinding.git", :tag => s.version.to_s }
  # s.social_media_url = ''

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Classes/*.swift'
  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '3.0',
  }
end
