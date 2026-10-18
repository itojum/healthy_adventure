require_relative 'compat'

# 原作の ranking.rb は Net::HTTP と eval を使うので、ブラウザでは動かない。
# bundle からは --ignore で外し、ゴール画面が呼ぶ ranking() は通信に失敗したことにする。
# goal() は $server_false が立っていればランキング表示を飛ばす。
def ranking
  $server_false = true
end

require './main.rb'
