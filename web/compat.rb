class Set
  def initialize(items = [])
    @items = []
    items.each { |item| add(item) }
  end

  def add(item)
    @items << item unless @items.include?(item)
    self
  end
  alias << add

  def delete(item)
    @items.delete(item)
    self
  end

  # 複製を回すので、途中で delete しても要素を読み飛ばさない
  def each(&block)
    @items.dup.each(&block)
    self
  end

  def select(&block)
    @items.select(&block)
  end

  def to_a
    @items.dup
  end

  def size
    @items.size
  end
end

# PicoRuby の rand は Range を受け付けないので、Range のときだけ整数に直して元の rand を呼ぶ。
def rand(*args)
  range = args[0]
  return super unless range.is_a?(Range)

  min  = range.first
  last = range.exclude_end? ? range.last - 1 : range.last
  min + super(last - min + 1)
end
