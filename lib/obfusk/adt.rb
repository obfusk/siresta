# --                                                            ; {{{1
#
# File        : obfusk/adt.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-13
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

# TODO: move to separate gem

module Obfusk
  module ADT
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def constructor(name, *keys, &b)
        self_ = self
        keys_ = keys.map(&:to_sym)
        name_ = name.to_sym
        ctor  = Class.new self
        ctor.class_eval do
          attr_accessor :cls, :ctor, :ctor_name
          define_method(:initialize) do |cls, ctor, *values|
            if !b && (k = keys_.length) != (v = values.length)
              raise ArgumentError, "wrong number of arguments (#{v} for #{k})"
            end
            data  = Hash[keys_.zip values]
            @cls  = cls; @ctor = ctor; @ctor_name = name_
            @data = b ? b[data] : data
          end
          keys_.each { |k| define_method(k) { @data[k] } }
        end
        class_eval do
          if !@constructors
            @constructors = superclass.ancestors.include?(::Obfusk::ADT) ?
                              superclass.constructors.dup : {}
          end
          @constructors[name_] = ctor
          define_singleton_method(name_) do |*values|
            ctor.new self_, ctor, *values
          end
          const_set name_, ctor
        end
      end
      private :constructor

      def constructors
        @constructors
      end

      def match(m, opts)
        unless m.cls == self
          raise ArgumentError, "types do not match (#{m.cls} for #{self})"
        end
        m.match opts
      end

      # TODO
      def inherited(subclass)
        puts "New subclass: #{subclass}"
      end
    end

    def match(opts)
      unless (ck = cls.constructors.keys.sort) == (ok = opts.keys.sort)
        raise ArgumentError,
          "constructors do not match (#{ok} for #{ck})"
      end
      opts[ctor_name][self]
    end
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
