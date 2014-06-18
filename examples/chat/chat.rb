require 'obfusk/data'
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

    def log_rooms(m)
      m.get_data(:rooms) { |rooms| puts "rooms: #{rooms}"; m.return nil }
    end

    handle :get_current_rooms do |m, h, p, b|
      log_rooms(m) >> m.get_data(:rooms) { |rooms| m.ok rooms.keys }
    end

    handle :join_room do |m, h, params, body|
      log_rooms(m) >> m.modify_data(:rooms) do |rooms|
        nick = body['nick']; room_name = params[:room]
        if Obfusk.get_in rooms, room_name, :users, nick
          m.error("nick '#{nick}' is taken") >> m.return(rooms)
        else
          token   = SecureRandom.hex 16
          rooms_1 = Obfusk.modify_in(rooms, room_name, :users) \
                      { |x| x.merge nick => token }
          rooms_2 = Obfusk.modify_in(rooms_1, room_name, :tokens) \
                      { |x| x.merge token => nick }
          m.ok(token: token, nick: nick) >> m.return(rooms_2)
        end
      end >> log_rooms(m)
    end

    handle :stream_messages_in_room do |m, h, p, b|
    end

    handle :post_to_room do |m, h, p, b|
    end
  end
end
