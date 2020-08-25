require_relative 'lib/hardware.rb'
require "pry"

games = Hardware.new(:switch).games
binding.pry
games
