# PicoRuby の rand は Range を受け付けない（TypeError: Range cannot be converted to Float）。
# 原作は rand(0..30) のように書いているので、整数の Range を受け付ける rand を用意する。
# script/build.rb がゲーム本体より前に読み込む。
alias __picoruby_rand rand

def rand(max = 0)
  if max.is_a?(Range)
    first = max.first
    last  = max.exclude_end? ? max.last - 1 : max.last
    first + __picoruby_rand(last - first + 1)
  else
    __picoruby_rand(max)
  end
end
