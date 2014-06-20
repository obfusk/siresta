# --                                                            ; {{{1
#
# File        : siresta/clients/js.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-19
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'erb'
require 'json'
require 'siresta/spec'

module Siresta
  module Clients
    module JS
      Template =
        File.read File.expand_path('../js.erb', __FILE__)
      ResourceTemplate =
        File.read File.expand_path('../js_resource.erb', __FILE__)

      # Generator for JS (sub)resource: wraps url, gets extended
      # as-needed w/ `.post`, `.get`, `.put`, `.delete`,
      # `.some_resource`, `(some_param)` etc.  Route methods take the
      # same arguments as jQuery's (and get the url and method merged
      # in).
      class Resource
        attr_accessor :name, :version, :methods, :routes, :w_param

        def initialize
          @methods = []; @routes = []; @name = @version = @w_param = nil
        end

        def to_js
          ERB.new(ResourceTemplate).result(binding) \
            .gsub(/^/, '  ').gsub(/\A\s+/, '')
        end

        def to_client_js(client_name)
          ERB.new(Template).result(binding).gsub(/^\s*\n/, '')
        end
      end
    end

    # generate a javascript client (source) based on a YAML
    # description
    def self.js(name, opts = {})
      Spec.walk Siresta.api_spec(opts), {
        root: -> (info) {
          info[:res].name     = info[:name]
          info[:res].version  = info[:version]
          info[:res].to_client_js name
        },
        resource: -> (info) {
          JS::Resource.new.tap { |res| res.methods += info[:methods] }
        },
        subresource: -> (info) {
          info[:res].routes << { route: info[:route], sub: info[:sub] }
        },
        parametrized_subresource: -> (info) {
          info[:res].w_param = { route: info[:route], sub: info[:sub] }
        },
      }
    end
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
