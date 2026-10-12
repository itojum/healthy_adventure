# require_stub.rb に続いて読み込む、PicoRuby に足りない標準機能の最小実装。

# PicoRuby には Set がないので、ゲームで使っている範囲だけを Array で実装する。
# each はスナップショットを回すので、ループ中に delete しても要素が飛ばされない。
class Set
  def initialize(items = [])
    @items = []
    items.each { |i| add(i) }
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

# PicoRuby の rand は Range を受け付けないので、Range のときだけ整数に展開する。
def rand(arg = nil)
  if arg.is_a?(Range)
    min = arg.first
    max = arg.exclude_end? ? arg.last - 1 : arg.last
    min + super(max - min + 1)
  elsif arg.nil?
    super()
  else
    super(arg)
  end
end
