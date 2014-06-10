require 'siresta/spec'

module Siresta
  def self.routes(file = DEFAULT_API_YAML)
    routes = []
    Spec.walk api_spec(file), {
      resource: -> (info) {
        info[:methods].each do |m|
          routes << [m.upcase, info[:path], info[:specs][m]['desc']]
        end
        nil
      },
      root: -> (_) {}, subresource: -> (_) {},
      parametrized_subresource: -> (_) {},
    }
    routes
  end
end
