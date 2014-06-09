require 'yaml'

module Siresta
  DEFAULT_API_YAML = 'config/api.yml'

  def self.api_spec(file = DEFAULT_API_YAML, cache = true)
    f = -> { YAML.load File.read(file) }
    @api_spec ||= {}
    cache ? @api_spec[file] ||= f[] : @api_spec[file] = f[]
  end

  def self.env
    ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
  end
end
