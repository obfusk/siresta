require File.expand_path('../lib/siresta/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'siresta'
  s.homepage    = 'https://github.com/obfusk/siresta'
  s.summary     = 'siRESTa - declarative REST APIs'

  s.description = <<-END.gsub(/^ {4}/, '')
    siRESTa is a DSL for declarative REST APIs.  It can generate a
    ruby API (w/ sinatra) and Client (w/ excon) for you, based on a
    YAML file.  Processing requests is done using a monad.
  END

  s.version     = Siresta::VERSION
  s.date        = Siresta::DATE

  s.authors     = [ 'Felix C. Stegerman' ]
  s.email       = %w{ flx@obfusk.net }

  s.licenses    = %w{ LGPLv3+ }

  s.files       = %w{ .yardopts README.md Rakefile siresta.gemspec } \
                + Dir['lib/**/*.rb']

  s.add_runtime_dependency 'excon'
# s.add_runtime_dependency 'hashie'
  s.add_runtime_dependency 'obfusk', '>= 0.1.1'
  s.add_runtime_dependency 'ox'
  s.add_runtime_dependency 'sinatra'

  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'yard'

  s.required_ruby_version = '>= 1.9.1'
end
