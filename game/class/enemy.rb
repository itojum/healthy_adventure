# 画像を分割したやつをおく
$a = 4

require './class/entity.rb'

class Enemy < Entity
  # 初期実行
  attr_reader :direction

  def initialize(x, y, image)
    super(x, y, image)

    @direction=-1
    @invincible = false
    @score = 0
    @cooltime = 0
  end
  
  def invincible
    @invincible
  end
  # 移動 オーバーライド用
  def move()
  end
  
  def cooltime()
    return @cooltime-=1
  end

  def bullet ()
    @cooltime = 10
    return Bullet.new(self.x, self.y, self, true)
 end

  def score
    @score
  end

  def hit(bullets)
    if self.invincible
      return
    end

    bullets.select{|e| e }.each do |bullet|
      next if bullet.isEnemy()
      if self === bullet
        return bullet
      end
    end
    return nil
  end
end