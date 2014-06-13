module Siresta
  # environment
  def self.env
    ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'
  end
end
