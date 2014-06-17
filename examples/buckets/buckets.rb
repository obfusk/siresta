require 'sequel'
require 'siresta'
require 'yaml'

module Buckets

  def self.connect
    return @db if @db

    @db = Sequel.connect \
      YAML.load(File.read('config/database.yml'))[Siresta.env]

    require './models/bucket'
    require './models/object'
    require './models/user'

    @db
  end

  API     = Siresta.api
  Client  = Siresta.client

  class API
    # ... TODO ...

    handle :list_buckets do
    end

    handle :create_bucket do
    end

    handle :get_bucket do
    end

    handle :update_bucket do
    end

    handle :delete_bucket do
    end

    handle :list_bucket_objects do
    end

    handle :create_bucket_object do
    end

    handle :get_bucket_object do
    end

    handle :update_bucket_object do
    end

    handle :delete_bucket_object do
    end

    handle :list_users do
    end

    handle :create_user do
    end

    handle :get_user do
    end

    handle :update_user do
    end

    handle :delete_user do
    end
  end
end
