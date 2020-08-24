# frozen_string_literal
require_relative './game.rb'
require_relative './base_page.rb'

ID_TABLE = {
  fc: '13', sfc: '14', n64: '15', gc: '16', wii: '17', wiiu: '3942', switch: '6695',
  ps: '22', ps2: '23', ps3: '24', ps4: '5139', xbox: '25', xbox360: '26', xboxone: '5506',
  md: '19', ss: '20', dc: '21', pce: '30', ng: '99', atari: '27', sms: '18', cv: '28',
  scv: '29', threedo: '98', playdia: '7060', pcfx: '91', vb: '570', oq: '7552'
}

# ハードウェア別のゲーム一覧ページ
class Hardware < BasePage

  # @return [Symbol]
  # @return [Hardware]
  def initialize(hardware_key)
    super(ID_TABLE[hardware_key])
  end

  # TODO(canisterism):
  #  ページによっては1000以上のhtmlをパースしてメモリに展開するので
  #  マシンスペック次第でメモリが足りなくなるかも？
  # @return [Array(Game)]
  def games
    @games ||= game_links.map do |game|
      Game.new(game[:id])
    end
  end

  # ゲームのタイトルと個別のページへのリンク
  # @return [Array(Hash<Symbol, String>)]
  def game_links
    @game_links ||= table_rows_with_head.filter(&:include_link?).map do |row|
      puts "#{row.page_id}:#{row.title}"
      { title: row.title, id: row.page_id }
    end
  end


  # private

  # ページ内の<tbody>の配列。
  # 各<tbody>は年別のゲームのリストになっている。
  # @return [Array(Nokogiri::XML::Element)]
  def tables
    doc.css('tbody')
  end

  # @param [Element] Nokogiriがパースしたピュアな<tr>
  def table_row_elements
    tables.map do |table|
      table.children.to_a.filter do |node|
        node.name == 'tr'
      end
    end.flatten
  end

  # ページ内の全ての<tr>を独自クラスでラップした配列(見出しを含む)
  # @return [Array(TableRow)]
  def table_rows_with_head
    table_row_elements.map do |element|
      Hardware::TableRow.new(element)
    end
  end

  # いわゆる<tr>。titleと個別のページへのリンクを持つ。
  class TableRow

    # @param [Element] Nokogiriがパースした<tr>
    # @return [TableRow]
    def initialize(row)
      @row ||= row
    end

    # @return [String] タイトル
    def title
      title_node.children.first.content
    end


    # @return [String] 個別のページのID
    def page_id
      # xxx.htmlにヒットする正規表現
      # [1]でアクセスしてidだけ取り出している
      Regexp.new('(\d.+)(\.[^.]+$)').match(raw_url)[1]
    end

    # private

    def row
      @row
    end

    def cells
      row.children
    end

    # @return [Boolean] この行にリンクを持つか
    # 「発売日」などの見出し行はfalse、それ以外の行はtrue
    def include_link?
      cells.to_a.any? do |cell|
        cell.children.any? { |node| node.name == 'a'}
      end
    end

    # <thead>に当たるセル
    # @return [Element] タイトルのリンクを持つセル
    def title_cell
      cells.to_a.find do |cell|
        cell.children.any? { |node| node.name == 'a'}
      end
    end

    # title_cellには余計な Nokogiri::XML::Textが混ざってるので除く
    # @return [Element] タイトルのリンクを持つ純粋なノード
    # { name = "a",
    #   attributes = [
    #     { name = "href", value = "//w.atwiki.jp/gcmatome/pages/xxx.html" } , ...],
    #   children = [ #(Text "THE TITLE")]
    # }
    def title_node
      title_cell.children.to_a.delete_if do |n|
        n.class == Nokogiri::XML::Text
      end.first
    end

    # @return [String] バックスラッシュ付きのURL
    # e.g. "//w.atwiki.jp/gcmatome/pages/xxx.html"
    def raw_url
      title_node.attributes['href'].value
    end

  end
end
