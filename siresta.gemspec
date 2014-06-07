require File.expand_path('../lib/siresta/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'siresta'
  s.homepage    = 'https://github.com/obfusk/siresta'
  s.summary     = '...'

  s.description = <<-END.gsub(/^ {4}/, '')
    ...
  END

  s.version     = Siresta::VERSION
  s.date        = Siresta::DATE

  s.authors     = [ 'Felix C. Stegerman' ]
  s.email       = %w{ flx@obfusk.net }

  s.licenses    = %w{ LGPLv3+ }

  s.files       = %w{ .yardopts README.md Rakefile siresta.gemspec } \
                + Dir['example/**/*[^~]'] + Dir['lib/**/*.rb']

  s.add_runtime_dependency 'sinatra'

# s.add_development_dependency 'rake'
# s.add_development_dependency 'rspec'

  s.required_ruby_version = '>= 1.9.1'
end
