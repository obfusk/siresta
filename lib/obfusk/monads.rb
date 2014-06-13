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

  class Either
    include ADT
    include Monad
    include MonadPlus

    constructor :Left , :value
    constructor :Right, :value

    def self.mreturn(x)
      Right(x)
    end
    def self.bind_pass(m, &b)
      m.match Left:   -> (_) { m },
              Right:  -> (x) { b[x.value] }
    end
  end

  class List
    include ADT
    include Monad
    include MonadPlus

    constructor :Nil
    constructor(:Cons, :head, :tail) do |data,f|
      { head: data[:head], tail: f ? Lazy.lazy(&f) : Lazy.lazy(data[:tail]) }
    end

    class Cons
      alias :_tail :tail
      def tail
        _tail[]
      end
    end

    def self.mreturn(x)
      Cons x, Nil()
    end

    # TODO
    # def self.bind_pass(m, &b)
    #   m.match Nil:  -> (_) { m },
    #           Cons: -> (x) {}     # concat (map f m)
    # end
  end

  module Lazy
    def self.lazy(x = nil, &b)
      return x if x.respond_to?(:__lazy__?) && x.__lazy__?
      f = b ? b : -> { x }; v = nil; e = false
      g = -> () { unless e then v = f[]; e = true end; v }
      g.define_singleton_method(:__lazy__?) { true }; g
    end
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
