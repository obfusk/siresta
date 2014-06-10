require 'yaml'

module Siresta
  DEFAULT_API_YAML = 'config/api.yml'

  module Spec
    METHODS = %w{ post get put delete }

    def self.walk(spec, opts)
      name    = spec['name']
      version = spec['version']
      res     = walk_resource spec['api'], '', opts
      opts[:root][{ res: res, name: name, version: version }]
    end

    def self.walk_resource(specs, path, opts)
      methods, codes = specs.inject([[],{}]) do |(ms,cs), spec|
        (m = (METHODS & spec.keys).first) ?
          [ms + [m], cs.merge(m => spec[m])] : [ms,cs]
      end
      opts[:resource][{ methods: methods, codes: codes, path: path }] \
        .tap { |res| walk_subresources res, specs, path, opts }
    end

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

  def self.api_spec(file = DEFAULT_API_YAML, cache = true)
    f = -> { YAML.load File.read(file) }
    @api_spec ||= {}
    cache ? @api_spec[file] ||= f[] : @api_spec[file] = f[]
  end
end
