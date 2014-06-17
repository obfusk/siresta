# --                                                            ; {{{1
#
# File        : siresta/api.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-16
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'obfusk/atom'
require 'sinatra/base'
require 'siresta/spec'

module Siresta
  module API
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def data(k, v)
        # ...
      end

      def convert_from(format, handler, &b)
        # ...
      end

      def convert_to(format, handler, &b)
        # ...
      end

      def handler(name, &b)
        define_method(name) do |method, path, app|
          b[Response].runResponse # ...
        end
      end

      def valid_body(name, &b)
        # ...
      end

      def valid_params(name, &b)
        # ...
      end
    end

    # this helper handles requests for generated routes
    def handle_request(method, path, &b)
      b[method, path, self]
    end
  end

  # generate an API (Sinatra::Base subclass) based on a YAML
  # description
  def self.api(opts = {})
    opts_     = opts.dup
    http_dsl  = opts_.delete(:http_dsl) || Sinatra::Base
    api       = Class.new http_dsl
    Spec.walk api_spec(opts_), {
      root: -> (info) {
        api.class_eval do
          enable :sessions if info[:sessions]   # TODO
          helpers Siresta::API
          set :name   , info[:name]
          set :version, info[:version]
        end
        api
      },
      resource: -> (info) {
        api.class_eval do
          info[:methods].each do |m|
            what  = "#{m.upcase} #{info[:path]}".inspect
            path  = info[:path].inspect
            code  = info[:specs][m][m] ||
                      "raise NotImplementedError, #{what}"
            class_eval %Q{
              #{m} #{path} do
                handle_request(#{m.to_sym.inspect}, #{path}) do
                  #{code}
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

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
