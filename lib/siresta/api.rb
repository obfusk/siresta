# --                                                            ; {{{1
#
# File        : siresta/api.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-17
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
      def gen_route(meth, path, formats, pipe, call)
        send(meth, path) do
          handle_request meth, path, formats, pipe, &method(call.to_sym)
        end
      end

      def handle(name, &b)
        define_method name, &b
      end

      def data(k, v)
      end

      def to_authorize(handler, &b)
      end

      def to_convert_from(format, handler, &b)
      end

      def to_convert_params(handler, &b)
      end

      def to_convert_to(format, handler, &b)
      end

      def to_validate_body(handler, &b)
      end

      def to_validate_params(handler, &b)
      end
    end

    # this helper handles requests for generated routes
    def handle_request(method, path, formats, pipeline, &b)
      m   = Response
      fs  = [
        # ...
        -> _ { b[m, :TODO_headers, params, request.body.read] }
        # ...
      ]
      m.pipeline(m.return(nil), *fs) # .runResponse ...
    end
  end

  # generate an API (Sinatra::Base subclass) based on a YAML
  # description
  def self.api(opts = {})
    opts_     = opts.dup
    http_dsl  = opts_.delete(:http_dsl) || Sinatra::Base
    api       = Class.new http_dsl
    api.class_eval { include Siresta::API }
    Spec.walk api_spec(opts_), {
      root: -> (info) {
        api.class_eval do
          enable :sessions if info[:sessions]   # TODO
          set :name   , info[:name]
          set :version, info[:version]
        end
        api
      },
      resource: -> (info) {
        api.class_eval do
          info[:methods].each do |m|
            gen_route m.to_sym, info[:path],
              info[:specs][m][:choices], info[:specs][m]['pipeline'],
              info[:specs][m][m]
          end
        end
        nil
      },
      subresource: -> (_) {}, parametrized_subresource: -> (_) {},
    }
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
