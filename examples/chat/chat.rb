require 'securerandom'
require 'siresta'

module Chat
  API     = Siresta.api
  Client  = Siresta.client

  class API
    set :server, :thin

    data :rooms, {}

    to_validate_params :join_room do
      (x = p[:room]) && x =~ /\A[A-Za-z0-9_-]+\z/
    end

    to_validate_body :join_room do
      (x = b['nick']) && x =~ /\A[A-Za-z0-9_-]+\z/
    end

    to_convert_from :xml, :join_room do
    end

    to_convert_to :xml, :join_room do
    end

    handle :get_current_rooms do |m|
      m.data(:rooms) { |rs| m.ok rs.keys }
    end

    handle :join_room do |m, headers, params, body|
      # TODO: check user exists + add info to room
      nick  = body['nick']
      token = SecureRandom.hex 16
      m.ok token: token
    end

    handle :stream_messages_in_room do |m|
    end

    handle :post_to_room do |m|
    end
  end
end
