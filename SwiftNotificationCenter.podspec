Pod::Spec.new do |s|
  s.name         = "SwiftNotificationCenter"
  s.version      = "1.0.0"
  s.summary      = "A Type Safe, Thread Safe, ARC Safe Protocol Oriented NotificationCenter"
  s.homepage     = "https://github.com/100mango/SwiftNotificationCenter"
  s.license  = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author             = { "100mango" => "https://github.com/100mango" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/100mango/SwiftNotificationCenter.git", :tag => s.version }
  s.source_files  = "SwiftNotificationCenter/*.swift"
  s.requires_arc = true
end
