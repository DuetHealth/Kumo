Pod::Spec.new do |s|
  s.name            = 'Kumo'
  s.version         = '3.0.0'
  s.summary         = 'Simple networking with little boilerplate built with reactive programming.'
  s.homepage        = 'https://github.com/DuetHealth/Kumo'
  s.license         = 'MIT'
  s.author          = 'ライアン'
  s.source          = { git: 'https://github.com/DuetHealth/Kumo.git', tag: "#{s.version}" }
  s.swift_version   = '6.0'

  s.ios.deployment_target = '18.0'
  s.osx.deployment_target = '15.0'
  s.tvos.deployment_target = '18.0'

  s.default_subspecs = 'Kumo', 'KumoCoding'

  s.subspec 'KumoCoding' do |sp|
    sp.name = 'KumoCoding'
    sp.source_files = 'Sources/KumoCoding/**/*.{h,m,swift}'
  end

  s.subspec 'Kumo' do |myLib|
    myLib.dependency 'Kumo/KumoCoding'
    myLib.source_files = 'Sources/Kumo/**/*.{h,m,swift}'
  end

end
