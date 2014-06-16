module Buckets
  class User < Sequel::Model
    one_to_many :buckets
  end
end
