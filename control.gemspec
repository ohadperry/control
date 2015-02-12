# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'rabbit_worker/version'

Gem::Specification.new do |s|
  s.name          = 'process_controller'
  s.version       = Control::VERSION
  s.authors       = ['ohad partuck']
  s.email         = ['ohadpartuck@gmail.com']
  s.homepage      = 'http://open-source.com'
  s.licenses      = ['MIT']
  s.summary       = %q{stop/start/restart}
  s.description   = %q{Generic Rstop/start/restart for processes}

  s.rubyforge_project = 'rabbit_worker'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  # s.add_dependency('rack_stats', '~> 0.2.2')
end
