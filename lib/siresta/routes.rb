# --                                                            ; {{{1
#
# File        : siresta/routes.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-13
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'siresta/spec'

module Siresta
  # get routes from YAML description
  def self.routes(opts = {})
    routes = []
    Spec.walk api_spec(opts), {
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

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
