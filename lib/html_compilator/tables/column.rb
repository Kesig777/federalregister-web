class HtmlCompilator::Tables::Column
  def self.generate(options)
    table = options.fetch(:table)
    table.node.attr('CDEF').split(/\s*,\s*/).map do |code|
      new(:table => table, :code => code)
    end
  end

  attr_reader :table, :code
  delegate :h, to: :table

  def initialize(options)
    @table = options.fetch(:table)
    @code = options.fetch(:code)
  end

  def width_in_points
    if code =~ /\D/
      code.gsub(/\D/,'').to_i
    else
      # figure columns are given as the number figures, not in points
      code.to_i * 5
    end
  end

  def alignment
    if figure?
      :right
    else
      :left
    end
  end

  def figure?
    code =~ /^\d/
  end

  def border_right
    case code[-1]
    when 'b'
      :bold
    when 'p'
      :double
    when 'n'
      :none
    end
  end

  def index
    table.columns.index(self)
  end

  def first?
    index == 0
  end

  def last?
    index + 1 == table.columns.size
  end
end
