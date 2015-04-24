class HtmlCompilator::Tables::HeaderCell < HtmlCompilator::Tables::Cell
  attr_reader :table, :node, :descendants
  attr_accessor :row, :max_level, :parent, :children

  def initialize(options)
    @table = options.fetch(:table)
    @node = options.fetch(:node)
  end

  def element
    :th
  end

  def alignment
    :center
  end

  def border_top
    if table.rules.include?(:horizonal) && row.first?
      table.top_border_style
    end
  end

  def border_bottom
    if table.rules.include?(:horizonal)
      :single
    end
  end

  def border_left
    if first_cell_in_row?
      table.rules.include?(:side) ? :single : nil
    end
  end

  def border_right
    if end_column.border_right
      end_column.border_right
    else
      if last_cell_in_row?
        table.rules.include?(:side) ? :single : nil
      else
        table.rules.include?(:down) ? :single : nil
      end
    end
  end

  def index
    row.all_cells.index(self)
  end

  def descendants=(descendants)
    @descendants = descendants

    @children = @descendants.select{|x| x.level == @descendants.first.level}

    @children.each{|x| x.parent = self}

    @descendants
  end

  def colspan
    if children.present?
      children.sum(&:colspan)
    else
      1
    end
  end

  def rowspan
    row_to_get_to = children.present? ? children.first.level-1 : max_level
    row_to_get_to - level + 1
  end

  def level
    @node.attr('H').to_i
  end

  def start_column_index
    if parent
      parent.start_column_index +
        previous_siblings.sum(&:colspan)
    else
      if previous_cell_in_row.nil?
        0
      else
        previous_cell_in_row.end_column_index + 1
      end
    end
  end

  def first_cell_in_row?
    start_column_index == 0
  end

  def previous_siblings
    parent.children.take_while{|x| x != self}
  end
end
