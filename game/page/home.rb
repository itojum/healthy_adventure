
def home()
  font = Font.new(90, font_name="HGP創英角ﾎﾟｯﾌﾟ体")
  Window.draw_font(100, Window.height / 2 - 50, "ヘルシーアドベンチャー", font, {:color => [0,100,0],:z => 120})
  font = Font.new(50)

  Window.draw_font(250, Window.height / 2 + 130, "Push Enter key to start", font, {:color => [255,105,180],:z => 120})
  
  abokadoimage = Image.load('image\charactor.png')
  abokado= Window.draw_scale(400, 0, abokadoimage, 0.6, 0.6, 0, 0)


  return Input.key_down?(K_RETURN)
end