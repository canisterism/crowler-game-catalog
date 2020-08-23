# frozen_string_literal

class Game
  # @param [String] スクレイピング対象のURL
  # @return [Game]
  def initialize(url)
    @tmpfile ||= URI.open(url)
    puts ''
  end

  # @return [Document] Nokogiriがパースしたドキュメント
  def doc
    @doc ||= Nokogiri::HTML.parse(@tmpfile)
  end
end
