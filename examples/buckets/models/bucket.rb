module Buckets
  class Bucket < Sequel::Model
    one_to_many :objects
    many_to_one :user
    many_to_many :users, :join_table => :shares
  end
end
