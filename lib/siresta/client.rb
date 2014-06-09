require 'excon'
require 'siresta/routes'

module Siresta
  class Resource
    attr_reader :url
    def initialize(url, *path)
      @url = ([url]+path)*'/'
    end
  end

  def self.client(file = DEFAULT_API_YAML, http_client = Excon) # {{{1
    _walk_spec api_spec(file), {
      client: -> (res, name, version) {
        res.class_eval do
          define_method(:name)    { name }
          define_method(:version) { version }
        end
      },
      resource: -> (methods, path) {
        res = Class.new Resource
        res.class_eval do
          methods.map(&:to_sym).each do |m|
            define_method(m) do |*params, &b|
              http_client.send m, url, *params, &b
            end
          end
        end
        res
      },
      subresource: -> (res, sub, r) {
        res.class_eval do
          define_method(r.to_sym) do
            sub.new url, r
          end
        end
      },
      parametrized_subresource: -> (res, sub, r) {
        res.class_eval do
          define_method(:[]) do |param|
            sub.new url, param
          end
        end
      },
    }
  end                                                           # }}}1
end
