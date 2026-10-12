# PicoRuby の rand との違いを埋める。script/build.rb がゲーム本体より前に読み込む。
#
# 1. Range を受け付けない
#    原作は rand(0..30) のように書くが、PicoRuby では
#    TypeError: Range cannot be converted to Float になる。
# 2. 1 回の呼び出しが重い
#    PicoRuby.wasm の rand は 1 回あたり 130〜150µs かかる（Sprite#=== の 10 倍以上）。
#    敵 40 体が毎フレーム呼ぶだけで 1 フレームに 14ms ほど使ってしまう。
#
# そこで、Ruby で書いた xorshift32 の乱数で rand を置き換える（1 回 3〜5µs）。
# 種だけは PicoRuby の rand から取る。ゲームの乱数としては十分な品質。
$__compat_rand_state = __send__(:rand, 0x7fffffff) | 1

def __compat_rand_next
  x = $__compat_rand_state
  x ^= (x << 13) & 0xFFFFFFFF
  x ^= x >> 17
  x ^= (x << 5) & 0xFFFFFFFF
  $__compat_rand_state = x
end

def rand(max = 0)
  if max.is_a?(Range)
    lo = max.begin
    hi = max.exclude_end? ? max.end - 1 : max.end
    return nil if hi < lo
    lo + __compat_rand_next % (hi - lo + 1)
  elsif max.is_a?(Integer) && max != 0
    __compat_rand_next % max.abs
  else
    f = __compat_rand_next / 4294967296.0
    max.is_a?(Float) && max != 0 ? f * max.abs : f
  end
end
