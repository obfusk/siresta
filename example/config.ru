require 'bundler/setup'
require './buckets'
Buckets.bootstrap
run Buckets::API
