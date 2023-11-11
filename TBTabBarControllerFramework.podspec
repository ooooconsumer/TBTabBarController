Pod::Spec.new do |spec|

  spec.name                     = 'TBTabBarControllerFramework'
  spec.version                  = '1.0.1'
  spec.summary                  = 'TBTabBarController is a versatile iOS framework for custom tab bar controllers with horizontal and vertical layouts, inspired by Tweetbot.'
  spec.description              = 'TBTabBarController offers a customizable and easy-to-use solution for managing tab-based navigation in your iOS app. With support for horizontal and vertical tab bars, custom tab bar items, and seamless transitions, it provides flexibility and control over your app\'s navigation. Inspired by the design principles of Tweetbot, TBTabBarController enhances your development experience, allowing you to create unique and engaging user interfaces effortlessly.'
  spec.homepage                 = 'https://github.com/ooooconsumer/TBTabBarController'
  spec.license                  = { :type => 'MIT', :file => 'LICENSE' }
  spec.author                   = { 'ooooconsumer' => 'avcdocntr@gmail.com' }
  spec.social_media_url         = 'https://twitter.com/ooooconsumer'
  spec.source                   = { :git => 'https://github.com/ooooconsumer/TBTabBarController.git', :tag => "#{spec.version}" }
  spec.ios.deployment_target    = '12.0'
  spec.platform                 = :ios, '12.0'
  spec.module_name              = 'TBTabBarControllerFramework'
  spec.public_header_files      = 'TBTabBarControllerFramework/Source/include/*.{h}'
  spec.private_header_files     = 'TBTabBarControllerFramework/Source/Private/*.{h}', 'TBTabBarControllerFramework/Source/Private/Categories/**/*.{h}'
  spec.source_files             = 'TBTabBarControllerFramework/Source/*.{m}', 'TBTabBarControllerFramework/Source/include/*.{h}', 'TBTabBarControllerFramework/Source/Private/*.{h,m}', 'TBTabBarControllerFramework/Source/Private/Categories/**/*.{h,m}'
  spec.preserve_paths           = 'TBTabBarControllerFramework/Source/**/*.{h,m}', 'TBTabBarControllerFramework/framework.modulemap'
  spec.module_map               = false

end