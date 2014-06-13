# --                                                            ; {{{1
#
# File        : siresta/api.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-13
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'sinatra/base'

require 'siresta/spec'

module Siresta
  module API
    # this helper handles requests for generated routes
    def handle_request(method, path, &b)
      puts "handle_request(#{method}, #{path}) ..."
      b[]                                                       # TODO
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
            }                                                   # TODO
          end
        end
        nil
      },
      subresource: -> (_) {}, parametrized_subresource: -> (_) {},
    }
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
