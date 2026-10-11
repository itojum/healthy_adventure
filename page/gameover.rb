$dark_image = Image.new(1024, 700, [128, 0, 0, 0]) 

def gameover()
  Window.draw(0, 0, $dark_image)

  font = Font.new(100)
  Window.draw_font(250, Window.height / 2 - 50, "GAMEOVER", font, {:color => [0,0,205],:z => 120})
  font = Font.new(50)
  Window.draw_font(420, Window.height / 2 + 80, "score: #{$score}", font, {:color => [100, 100, 255],:z => 120})

  Window.draw_font(250, Window.height / 2 + 130, "スペースでホームに戻る", font, {:color => [200, 200, 200],:z => 120})

  if Input.key_down?(K_SPACE)
    $page = 0
  end
end