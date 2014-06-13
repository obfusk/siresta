# --                                                            ; {{{1
#
# File        : siresta/spec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-13
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'yaml'

module Siresta
  DEFAULT_API_YAML = 'config/api.yml'

  module Spec
    METHODS = %w{ post get put delete }

    # walk spec
    def self.walk(spec, opts)
      name    = spec['name']
      version = spec['version']
      res     = walk_resource spec['api'], '', opts
      opts[:root][{ res: res, name: name, version: version }]
    end

    # process resource when walking spec
    def self.walk_resource(specs, path, opts)
      ms, ss = specs.inject([[],{}]) do |(ms,ss), spec|
        (m = (METHODS & spec.keys).first) ?
          [ms + [m], ss.merge(m => spec)] : [ms,ss]
      end
      opts[:resource][{ methods: ms, specs: ss, path: path }] \
        .tap { |res| walk_subresources res, specs, path, opts }
    end

    # process subresources when walking spec
    def self.walk_subresources(res, specs, path, opts)
      specs.each do |spec|
        if (r = spec['resource'])
          r_s = (p = Symbol === r) ? ":#{r}" : r
          sub = walk_resource spec['contains'], [path,r_s]*'/', opts
          opts[p ? :parametrized_subresource : :subresource][
            { res: res, sub: sub, parametrized: p, route: r,
              route_s: r_s, path: path }
          ]
        end
      end
    end
  end

  # get (cached) API spec
  # @param [Hash] opts            options
  # @option opts [String] :data   YAML data, or:
  # @option opts [String] :file   file name
  def self.api_spec(opts = {})
    if opts[:data]
      YAML.load opts[:data]
    else
      file = opts[:file] || DEFAULT_API_YAML
      (@api_spec ||= {})[file] ||= api_spec data: File.read(file)
    end
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
