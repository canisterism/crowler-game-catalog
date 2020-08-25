require 'nokogiri'
require 'open-uri'

class BasePage

  # @param [Int] スクレイピング対象のページのid
  # @return [Page]
  def initialize(id)
    @id = id
  end

  def url
    "https://w.atwiki.jp/gcmatome/pages/#{@id}.html"
  end

  # private

  # @return [Document] Nokogiriがパースしたドキュメント
  def doc
    @doc ||= Nokogiri::HTML.parse(URI.open(url))
  end

end
