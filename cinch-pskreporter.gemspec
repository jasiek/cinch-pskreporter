# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cinch/plugins/pskreporter/version'

Gem::Specification.new do |spec|
  spec.name          = "cinch-pskreporter"
  spec.version       = Cinch::Plugins::PSKReporter::VERSION
  spec.authors       = ["Jan Szumiec"]
  spec.email         = ["jan.szumiec@gmail.com"]

  spec.summary       = "Polls pskreporter.info every 10 minutes for reports for a particular callsign"
  spec.homepage      = "https://github.com/jasiek/cinch-pskreporter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "cinch-test", "~> 0"
  spec.add_development_dependency "byebug", "~> 0"

  spec.add_dependency "cinch", "~> 2"
  spec.add_dependency "hashie", "~> 0"
end
