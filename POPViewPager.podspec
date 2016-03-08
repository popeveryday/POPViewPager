Pod::Spec.new do |s|
s.name             = "POPViewPager"
s.version          = "0.1.0"
s.summary          = "POPViewPager is customable UIPageViewController with indicater tab bar for Object-c project."
s.homepage         = "https://github.com/popeveryday/POPViewPager"
s.license          = 'MIT'
s.author           = { "popeveryday" => "popeveryday@gmail.com" }
s.source           = { :git => "https://github.com/popeveryday/POPViewPager.git", :tag => s.version.to_s }
s.platform     = :ios, '7.1'
s.requires_arc = true
s.source_files = 'Pod/Classes/**/*.{h,m,c}'
s.dependency 'POPLib', '~> 0.1'
end