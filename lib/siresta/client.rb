# --                                                            ; {{{1
#
# File        : siresta/client.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-13
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'excon'

require 'siresta/spec'

module Siresta
  module Client
    # (sub)resource: wraps url, gets extendes as-needed w/ `.post`,
    # `.get`, `.put`, `.delete`, `.some_resource`, `[some_param]` etc.
    # Route methods take the same arguments as Excon's.
    class Resource
      attr_reader :url
      def initialize(url, *path)
        @url = ([url]+path)*'/'
      end
    end
  end

  # generate a client (Excon wrapper) based on a YAML description
  def self.client(opts = {})
    opts_       = opts.dup
    http_client = opts_.delete(:http_client) || Excon
    Spec.walk api_spec(opts_), {
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
            # resource.{get,post,put,delete}
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
          # resource.some_route
          define_method(info[:route].to_sym) do
            info[:sub].new url, info[:route]
          end
        end
      },
      parametrized_subresource: -> (info) {
        info[:res].class_eval do
          # resource[some_param]
          define_method(:[]) { |param| info[:sub].new url, param }
        end
      },
    }
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
