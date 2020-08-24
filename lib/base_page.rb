require 'nokogiri'
require 'open-uri'

class BasePage

  # @param [Int] スクレイピング対象のページのid
  # @return [Page]
  def initialize(id)
    @url = page_template(id)
  end

  def url
    @url
  end

  # private

  # @return [Document] Nokogiriがパースしたドキュメント
  def doc
    @doc ||= Nokogiri::HTML.parse(URI.open(url))
  end

  # @param [Int] ページのid
  # @return [String] URL
  def page_template(id)
    "https://w.atwiki.jp/gcmatome/pages/#{id}.html"
  end
end
