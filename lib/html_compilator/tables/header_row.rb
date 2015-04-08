class HtmlCompilator::Tables::HeaderRow
  def self.generate(options)
    table = options.fetch(:table)
    node = options.fetch(:node)

    cells = node.xpath('CHED').map do |cell_node|
      HtmlCompilator::Tables::HeaderCell.new(
        :table => table,
        :node => cell_node
      )
    end

    max_level = cells.map(&:level).max

    cells.each_with_index do |current_cell, i|
      current_cell.max_level = max_level
      current_cell.descendants = cells.
        slice(i+1, cells.size).
        take_while{|x| x.level > current_cell.level}
    end

    cells.group_by(&:level).sort_by(&:first).map do |level, cells|
      new(
        :table => table,
        :cells => cells
      )
    end
  end

  attr_reader :table, :cells
  delegate :h, :to => :table

  def initialize(options)
    @table = options.fetch(:table)
    @cells = options.fetch(:cells)
  end

  def to_html
    h.content_tag(:tr) {
      cells.each do |cell|
        h.concat cell.to_html
      end
    }
  end
end
