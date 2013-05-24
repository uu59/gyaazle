# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gyaazle/version'

Gem::Specification.new do |spec|
  spec.name          = "gyaazle"
  spec.version       = Gyaazle::VERSION
  spec.authors       = ["uu59"]
  spec.email         = ["k@uu59.org"]
  spec.description   = %q{Gyazo like image uploader to Google Drive}
  spec.summary       = %q{Gyazo like image uploader to Google Drive}
  spec.homepage      = "https://github.com/uu59/gyaazle"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
