Pod::Spec.new do |spec|

  spec.name         = "TweetbotTabBarController"
  spec.version      = "0.1.0"
  spec.summary      = "A replica of the Tweetbot solution with its vertical tab bar."
  spec.description  = "A replacement for UITabBarController with a vertical tab bar."
  spec.homepage     = "https://github.com/oofimaconsumer/TweetbotTabBarController"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { "oofimaconsumer" => "avcdoooo@gmail.com" }
  spec.social_media_url   = "https://twitter.com/oofimaconsumer"
  spec.source        = { :git => "https://github.com/oofimaconsumer/TweetbotTabBarController.git", :tag => "#{spec.version}" }
  spec.ios.deployment_target = "11.0"
  spec.frameworks    = 'CoreGraphics', 'UIKit'
  spec.platform      = :ios, "11.0"
  spec.requires_arc  = true
  spec.source_files  = "TweetbotTabBarController/**/*.{h,m}"

end