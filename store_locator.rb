#!/usr/bin/env ruby

require_relative './lib/geo_api'
require_relative './lib/input_validator'

require 'optparse'
require 'csv'

parsed_csv = CSV.read('store-locations.csv')
parsed_data = parsed_csv[1..-1]

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options]"

  opts.on '-z [INT]', '--zip [INT]', 'Find nearest store to this zip code.' do |zip|
    options[:zip] = zip
  end

  opts.on '-a [STRING]', '--address [STRING]', 'Find nearest store to this address' do |address|
    options[:address] = address
  end

  opts.on '-u [STRING]', '--units [STRING]', 'Display units in the miles or kilometers' do |units|
    options[:units] = units
  end

  opts.on '-o [STRING]', '--output [STRING]', 'Output in human-readable text or JSON' do |output|
    options[:output] = output
  end

  opts.on("-h", "--help", "show this help") do
    puts opts
    exit
  end
end.parse!

options[:data] = parsed_data
InputValidator.validate(options)

geo_api = GeoAPI.new(options)
geo_api.query
