# --                                                            ; {{{1
#
# File        : obfusk/monad.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-13
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

# TODO: move to separate gem

module Obfusk
  module Monad
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # inject a value into the monadic type
      #
      # implement me!
      def mreturn(x)
        raise NotImplementedError
      end

      # sequentially compose two actions; passing any value produced
      # by the first as an argument to the second when a block is
      # used; discarding any value produced by the first when no block
      # is used; see bind_pass, bind_discard
      #
      # ```
      # bind(m) { |x| k } # pass value
      # bind m, k         # discard value
      # ```
      def bind(m, k = nil, &b)
        b ? bind_pass(m, &b) : bind_discard(m, k)
      end

      # sequentially compose two actions, passing any value produced
      # by the first as an argument to the second
      #
      # implement me!
      def bind_pass(m, &b)
        raise NotImplementedError
      end

      # sequentially compose two actions, discarding any value
      # produced by the first
      #
      # implement me!
      def bind_discard(m, k)
        bind_pass(m) { |_| k }
      end

      # TODO
      # def fail
      #   raise NotImplementedError
      # end

      # map monad (i.e. functor)
      def fmap(m, f = nil, &b)
        g = f || b; bind(m) { |k| mreturn g[k] }
      end

      # flatten monad
      def join(m)
        bind(m) { |k| k }
      end

      # concatenate a sequence of binds
      def pipeline(m, *fs)
        fs.each { |f| m = bind(m, &f) }; m
      end

      # evaluate each action in the sequence from left to right, and
      # collect the results
      def sequence(*ms)
        ms.inject(mreturn []) do |m,k|
          bind(m) { |xs| bind(k) { |x| mreturn xs+[x] } }
        end
      end

      # evaluate each action in the sequence from left to right, and
      # ignore the results
      def sequence_(*ms)
        (ms + [mreturn(nil)]).inject { |m,k| bind(m, k) }
      end
    end

    def bind(k = nil, &b)
      self.class.bind self, k, &b
    end
    def fmap(f = nil, &b)
      self.class.fmap self, f, &b
    end
    def join
      self.class.join self
    end
    def pipeline(*fs)
      self.class.pipeline self, *fs
    end
    def sequence(*ms)
      self.class.sequence(self, *ms)
    end
    def sequence_(*ms)
      self.class.sequence_(self, *ms)
    end
  end

  module MonadPlus
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # identity
      def zero
        raise NotImplementedError
      end

      # associative operation
      def plus(m, k)
        raise NotImplementedError
      end
    end

    def plus(k)
      self.class.mplus self, k
    end
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
