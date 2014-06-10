require 'sinatra/base'
require 'siresta/spec'

module Siresta
  module API
    def handle_request(method, path, &b)
      puts "handle_request(#{method}, #{path}) ..."
      'TODO'
    end
  end

  def self.api(file = DEFAULT_API_YAML, http_dsl = Sinatra::Base)
    api = Class.new http_dsl
    Spec.walk api_spec(file), {
      root: -> (info) {
        api.class_eval do
          helpers Siresta::API
          set :name   , info[:name]
          set :version, info[:version]
        end
        api
      },
      resource: -> (info) {
        api.class_eval do
          info[:methods].each do |m|
            path = info[:path].inspect
            class_eval %Q{
              #{m} #{path} do
                handle_request(#{m.to_sym.inspect}, #{path}) do
                  #{info[:specs][m][m] || 'raise :TODO'}
                end
              end
            }
          end
        end
        nil
      },
      subresource: -> (_) {}, parametrized_subresource: -> (_) {},
    }
  end
end
