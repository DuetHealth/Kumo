Pod::Spec.new do |s|
  s.name            = 'Kumo'
  s.version         = '0.3.5'
  s.summary         = 'Simple networking with little boilerplate built with reactive programming.'
  s.homepage        = 'https://gitlab.duethealth.com/ios-projects/Dependencies/Kumo'
  s.license         = 'MIT'
  s.author          = 'ライアン'
  s.source          = { git: 'https://gitlab.duethealth.com/ios-projects/Dependencies/Kumo.git', tag: "#{s.version}" }
  s.swift_version   = '5.1'

  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'
  s.tvos.deployment_target = '11.0'

  s.default_subspecs = 'Kumo', 'KumoCoding'

  s.subspec 'KumoCoding' do |sp|
    sp.name = 'KumoCoding'
    sp.source_files = 'Sources/KumoCoding/**/*.{h,m,swift}'
  end

  s.subspec 'Kumo' do |myLib|
    myLib.dependency 'Kumo/KumoCoding'
    myLib.source_files = 'Sources/Kumo/**/*.{h,m,swift}'
    myLib.dependency 'RxSwift'
  end

end