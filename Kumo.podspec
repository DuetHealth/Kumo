Pod::Spec.new do |s|
  s.name            = 'Kumo'
  s.version         = '0.2.0'
  s.summary         = 'Simple networking with little boilerplate built with reactive programming.' 
  s.homepage        = 'https://gitlab.duethealth.com/ios-projects/experimental/Kumo'
  s.license         = 'MIT'
  s.author          = 'ライアン'
  s.source          = { git: 'https://gitlab.duethealth.com/ios-projects/experimental/Kumo.git', tag: "#{s.version}" }
  s.source_files    = 'Kumo/Sources/**/*.{h,m,swift}'
  s.swift_version   = '4.2'
  s.ios.deployment_target = '8.0'

  s.dependency 'RxSwift'

end
