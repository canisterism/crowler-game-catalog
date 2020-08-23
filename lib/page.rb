require_relative './game.rb'

## ハードウェア別のゲーム一覧ページ

class Page

  # @param [String] スクレイピング対象のURL
  # @return [Page]
  def initialize(url)
    @tmpfile ||= URI.open(url)
  end

  # TODO(canisterism):
  #  ページによっては1000以上のhtmlをパースしてメモリに展開するので
  #  マシンスペック次第でメモリが足りなくなるかも？
  # @return [Array(Game)]
  def games
    game_links.map do |item|
      Game.new(item[:url])
    end
  end

  # ゲームのタイトルと個別のページへのリンク
  # @return [Array(Hash<Symbol, String>)]
  def game_links
    table_rows_with_head.filter(&:include_link?).map do |row|
      { title: row.title, url: 'https://' + row.url }
    end
  end

  # private

  # @return [Document] Nokogiriがパースしたドキュメント
  def doc
    @doc ||= Nokogiri::HTML.parse(@tmpfile)
  end


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
      Page::TableRow.new(element)
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

    # @return [String] 個別のページへのURL
    def url
      raw_url.gsub(/\/\//, "")
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
