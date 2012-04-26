# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "active_web_service/version"

Gem::Specification.new do |s|
  s.name        = "active_web_service"
  s.version     = ActiveWebService::VERSION
  s.authors     = ["Anton Sozontov"]
  s.email       = ["asozontov@at-consulting.ru"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "active_web_service"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib', 'app/controllers']

  # specify any dependencies here; for example:
  s.add_development_dependency "rails"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "guard-rspec"

  s.add_runtime_dependency 'nokogiri'
  s.add_runtime_dependency 'libxml-ruby'
  s.add_runtime_dependency 'wsdl-reader'
  s.add_runtime_dependency 'actionpack'
end
