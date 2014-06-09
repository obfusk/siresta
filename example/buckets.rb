require 'sequel'
require 'siresta'
require 'yaml'

module Buckets

  def self.connect
    return @db if @db

    @db = Sequel.connect \
      YAML.load(File.read('config/database.yml'))['development']

    require './models/bucket'
    require './models/object'
    require './models/user'

    @db
  end

  API     = Siresta.api
  Client  = Siresta.client
end
