font = Font.new(32)
x = Window.width / 2
y = Window.height / 2

Window.loop do
  x += Input.x * 4
  y += Input.y * 4
  Window.draw_box_fill(x - 20, y - 20, x + 20, y + 20, C_GREEN)
  Window.draw_font(20, 20, "動くぞ...!", font)
end
