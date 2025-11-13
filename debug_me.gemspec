# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'debug_me/version'

Gem::Specification.new do |spec|
  spec.name          = 'debug_me'
  spec.version       = DebugMe::DEBUG_ME_VERSION
  spec.authors       = ['Dewayne VanHoozer']
  spec.email         = ['dvanhoozer@gmail.com']
  spec.summary       = 'A tool to print the labeled value of variables.'
  spec.description   = 'This thing is pretty old.  There are much better
ways of debugging in a complex application.  But,
you know, I keep returning to this little method
time after time.  I guess that marks me as a geezer.'
  spec.homepage      = 'http://github.com/MadBomber/debug_me'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.3.0'

  spec.metadata = {
    'homepage_uri'      => 'https://github.com/MadBomber/debug_me',
    'source_code_uri'   => 'https://github.com/MadBomber/debug_me',
    'bug_tracker_uri'   => 'https://github.com/MadBomber/debug_me/issues',
    'changelog_uri'     => 'https://github.com/MadBomber/debug_me/blob/master/CHANGELOG.md'
  }

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'amazing_print'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
