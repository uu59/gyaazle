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

  spec.add_dependency "httpclient"
  spec.add_dependency "multi_json"
  spec.add_dependency "nokogiri"
  spec.add_dependency "trollop"
  spec.add_dependency "launchy"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "webmock"
end
