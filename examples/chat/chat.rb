require 'securerandom'
require 'siresta'

module Chat
  API     = Siresta.api
  Client  = Siresta.client

  class API
    set :server, :thin

    data :rooms, {}

    valid_params :join_room do |p|
      (x = p[:room]) && x =~ /\A[A-Za-z0-9_-]+\z/
    end

    valid_body :join_room do |b|
      (x = b['nick']) && x =~ /\A[A-Za-z0-9_-]+\z/
    end

    convert_from :xml, :join_room do
    end

    convert_to :xml, :join_room do
    end

    handler :get_current_rooms do |m|
      m.data(:rooms) { |rs| m.ok rs.keys } >> m.json_response
    end

    handler :join_room do |m|
      m.validate_params(:join_room) >>
      m.param(:room) { |r|
        m.choose_request(m.json_request, m.xml_request(:join_room)) >>
        m.validate_body(:join_room) >>
        m.request_body { |b|
          # TODO: check user exists + add info to room
          nick  = b['nick']
          token = SecureRandom.hex 16
          m.ok token: token
        } >> m.choose_response(m.json_response, m.xml_response(:join_room))
      }
    end

    handler :stream_messages do |m|
    end

    handler :post_to_room do |m|
    end
  end
end
