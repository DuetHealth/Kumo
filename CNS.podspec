Pod::Spec.new do |s|
  s.name            = "CNS"
  s.version         = "0.1.0"
  s.summary         = "A shortish description of CNS."
  s.description     = <<-DESC
                   description description description description
                   description.
                   DESC
  s.homepage        = "https://foo.com/CNS"
  s.license         = "MIT"
  s.author          = "ライアン"
  s.source          = { git: "https://gitlab.duethealth.com/CNS.git", tag: "#{s.version}" }
  s.source_files    = 'CNS/Sources/**/*.{h,m,swift}'
  s.swift_version   = '4.1'
  s.ios.deployment_target = '8.0'

  s.dependency 'RxCocoa'
  s.dependency 'RxOptional'
  s.dependency 'RxSwift'

  s.dependency 'Chronicle'
end
