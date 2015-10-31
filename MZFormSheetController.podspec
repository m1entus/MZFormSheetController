Pod::Spec.new do |s|
  s.name     = 'MZFormSheetController'
  s.version  = '3.1.2'
  s.license  = 'MIT'
  s.summary  = 'Provides an alternative to the native iOS UIModalPresentationFormSheet.'
  s.homepage = 'https://github.com/m1entus/MZFormSheetController'
  s.authors  = 'Michał Zaborowski'
  s.source   = { :git => 'https://github.com/m1entus/MZFormSheetController.git', :tag => s.version.to_s }
  s.default_subspec = 'Core'
  s.requires_arc = true
  s.deprecated_in_favor_of = 'MZFormSheetPresentationController'
  s.dependency 'MZAppearance'

  s.subspec "Core" do |sp| 
    sp.source_files = 'MZFormSheetController/*.{h,m}'
  end

  s.platform = :ios, '6.1'
  s.frameworks = 'QuartzCore', 'Accelerate'
end
