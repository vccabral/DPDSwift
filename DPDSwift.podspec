Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "DPDSwift"
s.summary = "DPDSwift is an iOS library, that helps facilitate the use of Deployd for iOS Development."
s.requires_arc = true

s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '3.0',
  }
  
# 2
s.version = "0.1.2"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Steeven Sylveus" => "steevensylveus@gmail.com" }

# For example,
# s.author = { "Steeven Sylveus" => "steevensylveus@gmail.com" }


# 5 - Replace this URL with your own Github page's URL (from the address bar)
s.homepage = "https://github.com/ssylveus/DPDSwift"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/ssylveus/DPDSwift.git", :tag => "#{s.version}"}

# 7
s.framework = "UIKit"
s.dependency 'ObjectMapper', '~> 2.2'
#s.dependency 'ObjectMapper'

# 8
s.source_files = "DPDSwift", "DPDSwift/**/*.{swift}"

# 9
#s.resources = "RWPickFlavor/**/*.{png,jpeg,jpg,storyboard,xib}"
end
