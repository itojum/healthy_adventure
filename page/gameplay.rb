require 'set'

require './class/player.rb'
require './class/goal.rb'
require './init/block.rb'
require './init/enemy.rb'

$font = Font.new(25)

def initgame(chara_type)
   $blocks = initBlock()
  $enemys = initEnemy()
  $bullets = Set.new
  
  # sound = Sound.new( "./page/bgm/selectBGM.wav")  # .wav読み込み
  # sound.play 

  $player = Player.new(5, 10, chara_type)
  $goal = Goal.new(139, 0)
  

end


def play()
  # blocks処理
  $blocks.each do |block|
    block.update()
    if block.checkOutside
      $blocks.delete(block)
    end
    block.draw()
  end
  
  # enemy処理
  $enemys.each do |enemy|
    enemy.move()
    enemy.hitBlock($blocks)
    $enemys.delete(enemy) if enemy.outside()

    hit_bullet = enemy.hit($bullets)
    if hit_bullet != nil
      $enemys.delete(enemy)
      $bullets.delete(hit_bullet)
      $score += 10
    end
    #count=0
    
    if rand(0..10) == 0 && enemy.cooltime() < 0
      $bullets.add(enemy.bullet())
    
    end
    
    enemy.draw()
  end

  # bullets処理
  if Input.key_push?(K_SPACE) && $player.cooltime() <= 0
    $bullets.add($player.bullet())
  end
  $bullets.each do |bullet|
    next if bullet == nil

    bullet.update()
    if bullet.hitBlock($blocks.to_a) || bullet.checkOutside()
      $bullets.delete(bullet)
    end
    bullet.draw()
  end

  # player処理
  $goal.draw()
  $page = 4 if $goal.goal($player)

  $player.move()
  $player.hitBlock($blocks)
  if $player.hit($enemys.to_a.concat($bullets.select{|e| e}.select{|e| e.isEnemy()})) || $player.outside()
    $page = 3
  end
  $player.draw()

  Window.draw_font(0, 0, "score:#{$score}", $font, {:color => C_BLUE,:z => 100})
end