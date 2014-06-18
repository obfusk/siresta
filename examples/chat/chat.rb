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

    # to_convert_from :xml, :join_room do
    # end

    # to_convert_to :xml, :join_room do
    # end

    handle :get_current_rooms do |m, h, p, b|
      m.get_data(:rooms) { |rooms| m.ok rooms.keys }
    end

    handle :join_room do |m, h, params, body|
      m.get_data(:rooms) do |rooms|
        nick      = body['nick']
        room_name = params[:room]
        room      = rooms[room_name] || {}
        users     = room[:users]     || {}
        tokens    = room[:tokens]    || {}
        if users[nick]
          m.error "nick '#{nick}' is taken"
        else
          token   = SecureRandom.hex 16
          users_  = users.merge   nick => token
          tokens_ = tokens.merge  token => nick
          room_   = room.merge users: users_, tokens: tokens_
          rooms_  = rooms.merge room_name => room_
          m.set_data(:rooms, rooms_) >> m.ok(token: token, nick: nick)
        end
      end
    end

    handle :stream_messages_in_room do |m, h, p, b|
    end

    handle :post_to_room do |m, h, p, b|
    end
  end
end
