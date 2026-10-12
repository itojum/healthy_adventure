require "./ranking.rb"


def goal()
  if $ranking_players == nil && !$server_false
    ranking()
  end
  goalbackgroundImage = Image.load('image\goalbackground.jpg')
  Window.draw_scale(0, 0, goalbackgroundImage, 1, 0.59, 0, 0)

  font = Font.new(100, font_name="HGP創英角ﾎﾟｯﾌﾟ体")
  Window.draw_font(250, Window.height / 2 - 200, "GAMECLEAR!!", font, {:color => [	255,165,0],:z => 120})
  font = Font.new(50)
  Window.draw_font(420, Window.height / 2 - 50, "score: #{$score}", font, {:color => [100, 100, 255],:z => 120})

  if $ranking_players != nil
    ranking_image = Image.load('image\ranking.png')
    Window.draw_scale(0, 50, ranking_image, 1, 1, 0, 0)
    font = Font.new(25)
    $ranking_players.each_with_index do |player, index|
      color = [200, 200, 200]
      color = [255, 200, 0] if player[:name] == $player_name

      Window.draw_font(80, 60 * index + 150, "プレイヤー#{player[:name]}", font, {:color => color})
      Window.draw_font(80, 60 * index + 175, "score: #{player[:score]}", font, {:color => [100, 100, 255]})
    end
  end

  Window.draw_font(250, Window.height / 2 + 150, "スペースでホームに戻る", font, {:color => [0,255,127],:z => 120})

  if Input.key_down?(K_SPACE)
    $page = 0
  end
end