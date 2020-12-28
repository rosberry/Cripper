Pod::Spec.new do |spec|

  spec.name         = "Cripper"
  spec.version      = "1.0"
  spec.summary      = ""

  spec.homepage     = "https://github.com/rosberry/Cripper"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author       = { "Rosberry" => "develop@rosberry.com" }

  spec.swift_version = "5.0"
  spec.ios.deployment_target = "11.0"

  spec.source       = { :git => "https://github.com/rosberry/Cripper.git", :tag => "#{spec.version}" }

  spec.source_files  = "Cripper/Sources/*.{swift, h}"

end
