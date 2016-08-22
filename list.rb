#!/usr/bin/env ruby
require 'json'

puts JSON.parse(File.read(ARGV[0])).map { |v| v['snippet']['title'] }.join("\n")
