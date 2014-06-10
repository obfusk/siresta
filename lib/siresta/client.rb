require 'excon'
require 'siresta/spec'

module Siresta
  module Client
    class Resource
      attr_reader :url
      def initialize(url, *path)
        @url = ([url]+path)*'/'
      end
    end
  end

  def self.client(file = DEFAULT_API_YAML, http_client = Excon)
    Spec.walk api_spec(file), {
      root: -> (info) {
        info[:res].class_eval do
          define_method(:name)    { info[:name]     }
          define_method(:version) { info[:version]  }
        end
        info[:res]
      },
      resource: -> (info) {
        res = Class.new Client::Resource
        res.class_eval do
          info[:methods].map(&:to_sym).each do |m|
            define_method(m) do |*params, &b|
              # TODO: quoting
              http_client.send m, url, *params, &b
            end
          end
        end
        res
      },
      subresource: -> (info) {
        info[:res].class_eval do
          define_method(info[:route].to_sym) do
            info[:sub].new url, info[:route]
          end
        end
      },
      parametrized_subresource: -> (info) {
        info[:res].class_eval do
          define_method(:[]) { |param| info[:sub].new url, param }
        end
      },
    }
  end
end
