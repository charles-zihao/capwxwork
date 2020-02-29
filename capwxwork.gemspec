lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capwxwork/version'

Gem::Specification.new do |spec|
  spec.name          = 'capwxwork'
  spec.version       = Capwxwork::VERSION
  spec.authors       = ['Charles.Li']
  spec.email         = ['lizihao07@163.com']

  spec.summary       = %q{Send notification to wxwork about your Rails Capistrano deployment.}
  spec.description   = %q{Send notification to wxwork about your Rails Capistrano deployment.}
  spec.homepage      = 'https://github.com/lizihao0518/capwxwork'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
