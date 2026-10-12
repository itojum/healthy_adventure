# PicoRuby.wasm のブラウザ環境では仮想FSが空なので require は LoadError になる。
# ファイルの読み込みは index.html の <script type="text/ruby"> の並び順で行い、
# ゲーム側に残っている require / require_relative は何もしないメソッドで受け流す。
def require(path)
  true
end

def require_relative(path)
  true
end
