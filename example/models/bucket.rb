module Buckets
  class Bucket < Sequel::Model
    one_to_many :objects
    many_to_one :user
  end
end
