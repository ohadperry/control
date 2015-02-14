# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'control/version'

Gem::Specification.new do |s|
  s.name          = 'process_controller'
  s.version       = Control::VERSION
  s.authors       = ['ohad partuck']
  s.email         = ['ohadpartuck@gmail.com']
  s.homepage      = 'http://open-source.com'
  s.licenses      = ['MIT']
  s.summary       = %q{stop/start/restart}
  s.description   = %q{Generic stop/start/restart for processes}

  s.files         = `git ls-files`.split("\n")
  # s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  # s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'activesupport', '~> 4.2'

end
