Pod::Spec.new do |s|
  s.name         = "Arrange"
  s.version      = "0.2"
  s.summary      = "Little helper library for programmatic autolayout"



  s.homepage     = "https://github.com/szotp/Arrange"

  s.license      = "MIT (example)"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "szotp" => "qwertyszot@gmail.com" }

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/szotp/Arrange.git", :tag => 0.2}

  s.source_files  = "Arrange/*.swift"
end
