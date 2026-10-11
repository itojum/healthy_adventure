# PicoRuby には標準ライブラリの Set がないので、このゲームで使う分だけを用意する。
# script/build.rb が `require 'set'` をこのファイルに置き換える。
#
# CRuby の Set（中身は Hash）と同じく、
# - 同じ要素は 1 つしか持たない（nil を何度 add しても 1 つ）
# - each の途中で delete してよい（each は呼び出した時点の要素を順に返す）
class Set
  def initialize(items = nil)
    @items = []
    items.each { |item| add(item) } if items
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

  def include?(item)
    @items.include?(item)
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
  alias length size

  def empty?
    @items.empty?
  end
end
