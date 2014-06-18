# --                                                            ; {{{1
#
# File        : siresta/response.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-06-17
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'obfusk/adt'
require 'obfusk/monads'

module Siresta
  class Response < Obfusk::Monads::State
    class ResponseState
      include Obfusk::ADT
      constructor :ResponseState,
        :request, :response, :status, :api_obj
    end

    class RequestData
      include Obfusk::ADT
      constructor :RequestData, :headers, :body, :params # ...
    end

    class ResponseInfo
      include Obfusk::ADT
      constructor :ResponseInfo, :status, :headers, :data
    end

    class ResponseData
      include Obfusk::ADT
      constructor :ResponseEmpty
      constructor :ResponseBody,    :data
      constructor :ResponseStream,  :handle
    end

    class ResponseStatus
      include Obfusk::ADT
      constructor :ResponseContinue
      constructor :ResponseDone
      constructor :ResponseError, :message
    end

    [ ResponseState, RequestData, ResponseInfo ] \
      .each { |x| x.import_constructors self, false }

    [ ResponseData, ResponseStatus ] \
      .each { |x| x.import_constructors self }

    # -- constructor helpers --

    # add error to state
    def self._error(s, msg)
      s.clone(status: ResponseError(msg))
    end

    # call block with state if error (to short-circuit)
    def self._on_error(s, &b)
      b[s] if s.status.is_a? ResponseError
    end

    # call block with error state if done
    def self._on_done(s, &b)
      b[_error(s, 'cannot continue when done')] \
        if s.status.is_a? ResponseDone
    end

    # call block with error state if empty
    def self._on_empty(s, &b)
      b[_error(s, 'cannot use empty body')] \
        if s.response.data.is_a? ResponseEmpty
    end

    # call block with error state if stream
    def self._on_stream(s, &b)
      b[_error(s, 'cannot use body response')] \
        if s.response.data.is_a? ResponseStream
    end

    # -- constructors --

    # everything ok
    def self.ok(body, headers = {}, status = 200)
      modify -> s {
        _on_error(s)  { |t| return t }
        _on_done(s)   { |t| return t }
        _on_stream(s) { |t| return t }
        s.clone(
          response: s.response.clone(
            status: status, headers: s.response.headers.merge(headers),
            data: ResponseBody(body)
          ),
          status: ResponseContinue()
        )
      }
    end

    # everyting ok, stream data
    def self.stream(data, headers = {}, status = 200)
      # TODO
    end

    # everything ok, stream data (keep open)
    def self.stream_keep_open
      # TODO
    end

    # error!
    def self.error(msg)
      modify { |s| _error s, msg }
    end

    # ...

    # -- helpers --

    # get atom data
    def self.get_data(k, &b)
      x = get >> -> s { mreturn s.api_obj.data[k]._ }; b ? x >> b : x
    end

    # set atom data
    def self.set_data(k, v)
      get >> -> s { s.api_obj.data[k].swap! { |_| v }; mreturn nil }
    end

    # authorization
    def self.authorize(handler)
      # TODO
    end

    # convert parameters
    def self.convert_params(handler)
      # TODO
    end

    # validate body
    def self.validate_body(handler)
      # TODO
    end

    # validate parameters
    def self.validate_params(handler)
      # TODO
    end

    # -- formats --

    # convert request body from appropriate format
    def self.choose_request_format(handler, formats)
      modify -> s {
        _on_error(s)  { |t| return t }
        _on_done(s)   { |t| return t }
        b = s.api_obj.convert_from(handler, formats, s.request.body)
        s.clone(request: s.request.clone(body: b))
      }
    end

    # convert response body to appropriate format
    def self.choose_response_format(handler, formats)
      modify -> s {
        _on_error(s)  { |t| return t }
        _on_done(s)   { |t| return t }
        _on_empty(s)  { |t| return t }
        _on_stream(s) { |t| return t }
        b = s.api_obj.convert_to(handler, formats, s.response.data.data)
        s.clone(response: s.response.clone(data: ResponseBody(b)))
      }
    end
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
