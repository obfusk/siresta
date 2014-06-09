require 'siresta/env'

module Siresta
  METHODS = %w{ post get put delete }

  def self._walk_spec(spec, opts)
    name    = spec['name']
    version = spec['version']
    res     = _walk_resource spec['api'], '', opts
    opts[:client][res, name, version]
    res
  end

  def self._walk_resource(specs, path, opts)
    methods = specs.map { |x| METHODS & x.keys } .flatten.compact.uniq
    res     = opts[:resource][methods, path]
    _walk_subresources res, specs, path, opts
    res
  end

  def self._walk_subresources(res, specs, path, opts)
    specs.each do |spec|
      if (r = spec['resource'])
        r_s = (p = Symbol === r) ? ":#{r}" : r
        sub = _walk_resource spec['contains'], [path,r_s]*'/', opts
        opts[p ? :parametrized_subresource : :subresource][res, sub, r]
      end
    end
  end

  def self.routes(file = DEFAULT_API_YAML)
    routes = []
    _walk_spec api_spec(file), {
      resource: -> (methods, path) {
        methods.each do |m|
          routes << [m.upcase, path]
        end
      },
      client: -> (res, name, version) {},
      subresource: -> (res, sub, r) {},
      parametrized_subresource: -> (res, sub, r) {},
    }
    routes
  end
end
