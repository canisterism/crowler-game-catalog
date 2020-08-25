# frozen_string_literal

require 'logger'
require_relative './base_page.rb'
log = Logger.new('/tmp/log')

class Game < BasePage

  def initialize(title:, id:)
    @title = title
    super(id)
  end

  # @return [String]
  def title
    @title
  end

  # @return [Date]
  def published_at
    basic_info.published_at
  end

  # @return [String]
  def published_from
    basic_info.published_from
  end

  # @return [Array(String?)]
  def hardwares
    basic_info.hardwares
  end

  # @return [String]
  def image_url
    basic_info.image_url
  end

  # private

  # @return [Game::BasicInfo]
  def basic_info
    @basic_info ||= BasicInfo.new(basic_info_table_rows)
  end

  # ページの最初の<tbody>の子nodeのリスト(Textは除外済み)
  # @return [Array(Nokogiri::XML::Element)]
  def basic_info_table_rows
    @basic_info_table_rows ||= doc.css('tbody').to_a.first.children.to_a.delete_if do |node|
      node.class == Nokogiri::XML::Text
    end
  end

  # 発売日とか対応プラットフォームとかの情報を持つ<tbody>のラッパー
  class BasicInfo
    # @param [Array(Nokogiri::XML::Element)] <tr>の配列になってるはず
    # @return [Game::BasicInfo]
    def initialize(rows)
      @rows = rows
    end

    # @return [String] テーブル内で先頭に表示されている画像のURL。だいたいamazonのはず。
    def image_url
      @image_url = image_tag.attr('data-original')
    end

    # @return [Date]
    def published_at

      raw_text = published_at_row.elements.at('td:contains(発売日)').next_element.text
      # yyyy年mm月dd日のフォーマット
      date_array = Regexp.new('(\d{4})年(\d{1,2})月(\d{1,2})日').match(raw_text).captures.map(&:to_i)
      @published_at = Date.new(date_array[0], date_array[1], date_array[2])
    rescue => e
      log.warn("published_at: e#{e}")
    end

    # @return [String]
    def published_from
      @published_from = 'スクウェア・エニックス'
    end

    # @return [Array(String?)]
    def hardwares
      @hardwares = ['switch']
    end

    # private

    # @return [Nokogiri::XML::NodeSet]
    def rows
      @rows
    end

    # @return [Nokogiri::XML::Element] テーブル内で先頭に表示されている画像のタグ
    def image_tag
      rows.children.css('img').first
    end

     # @return [Nokogiri::XML::Element] <tr>を返す
    def genre_row
      find_row_contains(keyword: 'ジャンル')
    end

     # @return [Nokogiri::XML::Element] <tr>を返す
    def hardwares_row
      find_row_contains(keyword: '対応機種')
    end

     # @return [Nokogiri::XML::Element] <tr>を返す
    def published_from_row
      find_row_contains(keyword: '発売元')
    end

     # @return [Nokogiri::XML::Element] <tr>を返す
    def published_at_row
      find_row_contains(keyword: '発売日')
    end

     # @return [Nokogiri::XML::Element] <tr>を返す
    def price_row
      find_row_contains(keyword: '定価')
    end

    # rowsの中からキーワードを持つrow(tr)を返す
    # @params [String]
    # @params [Nokogiri::XML::Element]
    def find_row_contains(keyword:)
      rows.find { |row| !row.at("td:contains('#{keyword}')").nil? }
    end
  end


end
