# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'debug_me/version'

Gem::Specification.new do |spec|
  spec.name          = 'debug_me'
  spec.version       = DebugMe::VERSION
  spec.authors       = ['Dewayne VanHoozer']
  spec.email         = ['dvanhoozer@gmail.com']
  spec.summary       = 'A tool to print the labeled value of variables.'
  spec.description   = 'This thing is pretty old.  There are much better
ways of debugging in a complex application.  But,
you know, I keep returning to this little method
time after time.  I guess that marks me as a geezer.'
  spec.homepage      = 'http://github.com/MadBomber/debug_me'
  spec.license       = 'You want it, its yours'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_dependency 'version_info', '~> 1.9.0'
end
