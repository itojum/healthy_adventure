require 'dxruby'
require './page/gameover.rb'
require './page/gameplay.rb'
require './page/home.rb'

require"./class/bgm.rb"
# bgm = Bgm.new(["./page/bgm/gameBGM.wav", "./page/bgm/selectBGM.wav","./page/bgm/gameBGM.wav"])
bgm = Bgm.new(["./page/bgm/selectBGM.wav"] * 3)
require './page/goal.rb'
require './page/player_select.rb'

backgroundImage = Image.load('image/background1.png')

Window.width  = 1024
Window.height = 700
Window.caption = "ヘルシーアドベンチャー"
$score = 0
background_x=0

def initFunc 
  $score = 0
  background_x = 0
  # initgame()
end

#0 = ホーム, 1 = ゲーム, 2 = ゲームオーバー 3 = ゴール
#0=home,1=select,2=game,3=gameover,4=goal
$page = 0
chara_type=1

Window.loop do
  background = Window.draw_scale(background_x, 0, backgroundImage, 1, 0.5, 0, 0)

  case $page
  when 0
    if home()
        initFunc()
        $page = 1
    end
  when 1

    bgm.set_bgm($page)
   # p "after set BGM"
    if bgm.playing?
    
    else 
     # p "BGM"
    bgm.play
    end


    chara_type=p_select()
    initgame(chara_type)
    $page=2
  when 2

    if background_x>=-1024
      background_x-=1
    else
      background_x=0
    end
    
    play
  
  when 3
    gameover()
  when 4
    goal()
  end
end
