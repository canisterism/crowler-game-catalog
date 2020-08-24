require 'nokogiri'
require 'open-uri'

class BasePage

  # @param [Int] スクレイピング対象のページのid
  # @return [Page]
  def initialize(id)
    binding.pry
    @tmpfile = URI.open(page_template(id))
  end

  # private

  # @return [Document] Nokogiriがパースしたドキュメント
  def doc
    @doc ||= Nokogiri::HTML.parse(@tmpfile)
  end

  # @param [Int] ページのid
  # @return [String] URL
  def page_template(id)
    "https://w.atwiki.jp/gcmatome/pages/#{id}.html"
  end
end
