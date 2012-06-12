# -*- encoding: utf-8 -*-
require File.expand_path('../lib/jenkins-capistrano/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["cynipe"]
  gem.email         = ["cynipe@gmail.com"]
  gem.description   = %q{The capistrano tasks for Jenkins CI Server}
  gem.summary       = %q{}
  gem.homepage      = "https://github.com/cynipe/jenkins-capistrano"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "jenkins-capistrano"
  gem.require_paths = ["lib"]
  gem.version       = Jenkins::Capistrano::VERSION

  gem.add_dependency 'capistrano'
  gem.add_dependency 'httparty',  '~> 0.8.3'
  gem.add_dependency 'hpricot'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'pry'
end
