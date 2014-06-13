# --                                                            ; {{{1
#
# File        : obfusk/monads.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-13
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

# TODO: move to separate gem

require 'obfusk/adt'
require 'obfusk/monad'

module Obfusk
  module Monads
    class Maybe
      include ADT
      include Monad
      include MonadPlus

      constructor :Nothing
      constructor :Just, :value

      def self.mreturn(x)
        Just(x)
      end
      def self.bind_pass(m, &b)
        m.match Nothing:  -> (_) { Nothing()  },
                Just:     -> (x) { b[x.value] }
      end
    end

    # TODO
    class MaybeWTF < Maybe
      constructor :WTF, :really
    end
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
