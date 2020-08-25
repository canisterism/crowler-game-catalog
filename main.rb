require_relative 'lib/hardware.rb'
require "pry"

b = Hardware.new(:switch).games[1]
binding.pry
b
