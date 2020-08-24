require_relative 'lib/hardware.rb'
require "pry"

hardware = Hardware.new(:ps2)

binding.pry
hardware
