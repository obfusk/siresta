# --                                                            ; {{{1
#
# File        : siresta/response.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-16
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'obfusk/adt'
require 'obfusk/lazy'
require 'obfusk/monad'

module Siresta
  class Response
    # TODO:
    #   :BodyResponse, :status, :headers, :body
    #   :StreamResponse, :status, :headers, :data
    #   :OK, :Error

    include Obfusk::ADT
    include Obfusk::Monad
    include Obfusk::MonadPlus

    constructor :Response, :runResponse

    # -- constructors --

    def self.ok(body, headers = {}, status = 200)
      b = body.is_a?(String) ? [b] : b
      :TODO
    end

    def self.stream(data, headers = {}, status = 200)
      :TODO
    end

    def self.stream_keep_open
    end

    def self.error
    end

    # ...

    # -- monad --

    def self.mreturn(x)
    end

    def self.bind_pass(m, &b)
    end

    def self.zero
    end

    def self.lazy_plus(m, k)
    end

    # -- helpers --

    def self.data
    end

    def self.param
    end

    def self.request_body
    end

    def self.validate_body
    end

    def self.validate_params
    end

    # -- formats --

    def self.choose_request
    end

    def self.choose_response
    end

    def self.json_request
    end

    def self.json_response
    end

    def self.xml_request
    end

    def self.xml_response
    end
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
