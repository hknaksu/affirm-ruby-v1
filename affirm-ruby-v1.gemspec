# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "affirm/version"

Gem::Specification.new do |spec|
  spec.name = "affirm-ruby-v1"
  spec.version = Affirm::VERSION
  spec.authors = ["Yury Velikanau", "Igor Pstyga"]
  spec.email = ["yury.velikanau@gmail.com"]
  spec.summary = "Ruby wrapper for the Affirm v1 Transactions API"
  spec.description = "Ruby client for Affirm.com /api/v1/transactions with compatibility helpers for legacy affirm-ruby call sites."
  spec.homepage = "https://github.com/hknaksu/affirm-ruby-v1"
  spec.license = "MIT"

  spec.files = Dir.chdir(__dir__) { Dir["{lib,spec}/**/*", "README.md", "LICENSE.txt", "CHANGELOG.md", "Gemfile", ".rspec", "Rakefile"] }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.1"
  spec.add_dependency "bigdecimal"
  spec.add_dependency "logger"
  spec.add_dependency "ostruct"
  spec.add_dependency "faraday", ">= 2.10", "< 3.0"
  spec.add_dependency "virtus", "~> 1.0", ">= 1.0.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "byebug"
end
