# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'solvemedia/version'

Gem::Specification.new do |gem|
  gem.name          = "solvemedia"
  gem.version       = SolveMedia::VERSION
  gem.authors       = ["Tyler Cunnion"]
  gem.email         = ["tyler@solvemedia.com"]
  gem.description   = %q{Solve Media CAPTCHA Replacement}
  gem.summary       = %q{Library for implementing the Solve Media CAPTCHA solution.
                        Contains basic Ruby library plus Railtie for Rails 3+.}
  gem.homepage      = "http://www.solvemedia.com/"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
