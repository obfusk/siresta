module Buckets
  class Object < Sequel::Model
    many_to_one :bucket
  end
end
