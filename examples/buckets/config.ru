require 'bundler/setup'
require './buckets'
Buckets.connect
run Buckets::API
