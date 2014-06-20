# --                                                            ; {{{1
#
# File        : siresta/spec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-19
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

    class RouteConflictError < RuntimeError; end

    # walk spec
    def self.walk(spec, opts)
      name      = spec['name']
      version   = spec['version']
      sessions  = spec['sessions']
      formats   = { request:  spec['request_formats']   || [],
                    response: spec['response_formats']  || [] }
      res       = walk_resource spec['api'], '/', opts, formats
      opts[:root][{
        res: res, name: name, version: version, sessions: sessions
      }]
    end

    # process resource when walking spec
    def self.walk_resource(specs, path, opts, formats)
      ms, ss = specs.inject([[],{}]) do |(ms,ss), spec|
        chs = formats.merge({ request: spec['request_formats'],
                              response: spec['response_formats'] }
                            .reject { |k,v| !v })
        (m = (METHODS & spec.keys).first) ?
          [ms + [m], ss.merge(m => spec.merge(formats: chs))] : [ms,ss]
      end
      opts[:resource][{ methods: ms, specs: ss, path: path }] \
        .tap { |res| walk_subresources res, specs, path, opts, formats, ms }
    end

    # process subresources when walking spec
    def self.walk_subresources(res, specs, path, opts, formats, methods)
      specs.each do |spec|
        if (r = spec['resource'])
          r_s = (p = Symbol === r) ? ":#{r}" : r
          pth = (path == '/' ? '' : path) + '/' + r_s
          raise RouteConflictError,
            "route #{pth} conflicts with a method supported by its parent" \
              if !p && methods.include?(r.to_s)
          chs = formats.merge({ request: spec['request_formats'],
                                response: spec['response_formats'] }
                              .reject { |k,v| !v })
          sub = walk_resource spec['contains'], pth, opts, chs
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
