# --                                                            ; {{{1
#
# File        : siresta/api.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-18
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'json'
require 'obfusk/atom'
require 'sinatra/base'
require 'siresta/response'
require 'siresta/spec'

module Siresta
  module API
    # handle request for generated route
    def _handle_request(meth, path, formats, pipe, handler)
      b   = method handler
      r   = Response
      fs  = []  # TODO

      fs << r.choose_request_format(handler, formats) \
        unless formats[:request].empty?
      fs << r.get
      fs << -> s { b[r, s.request.headers, s.request.params, s.request.body] }
      fs << r.choose_response_format(handler, formats) \
        unless formats[:response].empty?

      x   = r.pipeline(r.return(nil), *fs)
      s   = x.exec _begin_state

      # TODO
      if s.status.is_a? r::ResponseError
        [500, s.status.message]
      elsif s.response.data.is_a? r::ResponseBody
        [s.response.status, s.response.headers, s.response.data.data]
      else
        raise 'OOPS'  # TODO
      end
    end

    # begin state for Response monad
    def _begin_state
      r = Response
      r.ResponseState(
        r.RequestData(
          {}, # TODO: headers
          request.body.read, params
        ),
        r.ResponseInfo(nil, {}, r.ResponseEmpty()),
        r.ResponseContinue(), self
      )
    end

    # preferred formats
    def preferred_formats(formats)
      @preferred_formats ||= {}
      return @preferred_formats[formats] if @preferred_formats[formats]
      fmts  = formats[:request] | formats[:response]
      m2f   = Hash[fmts.map { |x| [mime_type(x), x] }]
      f_in  = m2f[request.content_type] || formats[:request].first
      f_out = m2f[request.preferred_type m2f.keys]
      @preferred_formats[formats] = [f_in, f_out]
    end

    # convert from preferred format
    def convert_from(handler, formats, body)
      f_in, f_out = preferred_formats formats
      ss          = settings.siresta[:convert_from][f_in] || {}
      f           = ss[handler] || ss[:__all__]
      f ? f[body] : raise('OOPS')   # TODO
    end

    # convert to preferred format
    def convert_to(handler, formats, body)
      f_in, f_out = preferred_formats formats
      ss          = settings.siresta[:convert_to][f_out] || {}
      f           = ss[handler] || ss[:__all__]
      f ? f[body] : raise('OOPS')   # TODO
    end

    # atoms
    def siresta_data
      settings.siresta[:data]
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # generate route
      def _gen_route(meth, path, formats, pipe, handler)
        send(meth, path) do
          _handle_request meth, path, formats, pipe, handler
        end
      end

      # named handler
      def handle(name, &b)
        define_method name, &b
      end

      # declare data (atom)
      def data(k, v)
        settings.siresta[:data][k] = Obfusk.atom v
      end

      # handle authorization
      def to_authorize(handler, &b)
        settings.siresta[:authorize][handler] = b
      end

      # convert body from format
      def to_convert_from(format, handler = :__all__, &b)
        (settings.siresta[:convert_from][format] ||= {})[handler] = b
      end

      # convert params
      def to_convert_params(handler, &b)
        settings.siresta[:convert_params][handler] = b
      end

      # convert body to format
      def to_convert_to(format, handler = :__all__, &b)
        (settings.siresta[:convert_to][format] ||= {})[handler] = b
      end

      # validate body
      def to_validate_body(handler, &b)
        settings.siresta[:validate_body][handler] = b
      end

      # validate params
      def to_validate_params(handler, &b)
        settings.siresta[:validate_params][handler] = b
      end
    end
  end

  class ApiBase < Sinatra::Base
    include Siresta::API

    set :siresta, { data: {}, authorize: {}, convert_from: {},
                    convert_params: {}, convert_to: {},
                    validate_body: {}, validate_params: {} }

    to_convert_from :json do |body|
      body.empty? ? nil : JSON.parse(body)
    end

    to_convert_to :json do |data|
      data.to_json
    end
  end

  # generate an API (Sinatra::Base subclass) based on a YAML
  # description
  def self.api(opts = {})
    api = Class.new ApiBase
    Spec.walk api_spec(opts), {
      root: -> (info) {
        api.class_eval do
          enable :sessions if info[:sessions]   # TODO
          set :name   , info[:name]
          set :version, info[:version]
        end
        api
      },
      resource: -> (info) {
        api.class_eval do
          info[:methods].each do |m|
            formats = info[:specs][m][:formats]
            symfmts = Hash[formats.map { |k,v| [k,v.map(&:to_sym)] }]
            _gen_route m.to_sym, info[:path], symfmts,
              info[:specs][m]['pipeline'], info[:specs][m][m].to_sym
          end
        end
        nil
      },
      subresource: -> (_) {}, parametrized_subresource: -> (_) {},
    }
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
