# PicoDX の最小構成の動作確認用。矢印キーで四角が動けば、PicoDX と PicoRuby.wasm が動いている。
# 次の PR で、このファイルを原作（Ruby合宿2024春 Team5）の main.rb に置き換える。
font = Font.new(32)
x = Window.width / 2
y = Window.height / 2

Window.loop do
  x += Input.x * 4
  y += Input.y * 4
  Window.draw_box_fill(x - 20, y - 20, x + 20, y + 20, C_GREEN)
  Window.draw_font(20, 20, "PicoDX: 矢印キーで動かす", font)
end
