require_relative 'lib/page.rb'
require "pry"

urls = {:switch: 'https://w.atwiki.jp/gcmatome/pages/6695.html'}
page = Page.new(urls[:switch])

# binding.pry
page
