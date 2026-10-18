# PicoRuby に足りない標準機能のうち、原作が使っている分だけを補う。
# 原作（game/）は DXRuby で動くまま残すので、ここはブラウザ用の入口からだけ読み込む。

# PicoRuby には Set がないので、ゲームで使っている範囲だけを Array で実装する。
# 原作は each の途中で delete するので、each は複製を回して要素を読み飛ばさないようにする。
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
