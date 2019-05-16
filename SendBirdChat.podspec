
Pod::Spec.new do |s|
s.name         = "SendBirdChat"
s.version      = "1.0"
s.summary      = "Sendbird Chat Cache"
s.description  = <<-DESC
A much much longer description of MyFramework.
DESC
s.homepage     = "https://github.com/mzahidimran/SendBirdCache"
s.license      = "MIT"
s.author       = { "Zahid" => "m_zahidimran@yahoo.com" }
#s.source       = { :path => "." }
s.dependency 'SendBirdSDK', '~> 3.0.122'
s.source       = { :git => "https://github.com/mzahidimran/SendBirdCache.git", :tag => "#{s.version}" }
s.source_files  = "SendBirdChat/**/*.*"
s.exclude_files = "SendBirdChat/**/*.plist"
s.ios.deployment_target  = '10.0'
s.swift_version = '4.2'
s.resource_bundles = {'SendBirdChat' => ['SendBirdChat/SendBirdChat.xcdatamodeld']}
end
