Pod::Spec.new do |s|
  s.name     = 'MZFormSheetController'
  s.version  = '0.0.2'
  s.license  = 'MIT'
  s.summary  = 'Provides an alternative to the native iOS UIModalPresentationFormSheet.'
  s.homepage = 'https://github.com/m1entus/MZFormSheetController'
  s.authors  = 'Michael Zaborowski'
  s.source   = { :git => 'https://github.com/m1entus/MZFormSheetController.git', :tag => '0.0.2' }
  s.source_files = 'MZFormSheetController'
  s.requires_arc = true

  s.platform = :ios, '5.0'
  s.frameworks = 'QuartzCore'
end