# PicoRuby の rand との違いを埋める。script/build.rb がゲーム本体より前に読み込む。
#
# PicoRuby の rand は Range を受け付けない。原作は rand(0..30) のように書くが、
# PicoRuby では TypeError: Range cannot be converted to Float になる。
# そこで、整数の Range が渡されたら、PicoRuby の rand(n) を使って同じ範囲の値を返す。
alias __picoruby_rand rand

def rand(max = 0)
  if max.is_a?(Range)
    lo = max.begin
    hi = max.exclude_end? ? max.end - 1 : max.end
    return nil if hi < lo
    lo + __picoruby_rand(hi - lo + 1)
  else
    __picoruby_rand(max)
  end
end
