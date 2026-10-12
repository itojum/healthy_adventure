"""
キャラクターが進んでいる方向に
たまをだせるようにする
"""


class Bullet < Sprite
    attr_accessor :score
  
    def initialize(x, y, chara, enemy = false)
      @facing = chara.facing
      self.x, self.y = x, y

      
      self.image = chara.bullet_image
      self.scale_x *= @facing

      @speed = 7
      @isEnemy = enemy
     
    end
  
    def update
      self.x += @facing * @speed -1
    end
    
    def isEnemy()
      return @isEnemy
    end

    def checkOutside
      return self.x < -128 || self.x > 1024 || self.y < 0 || self.y > 700
    end
    def hitBlock(blocks)
      blocks.each do |block|
        if self === block
          return true
        end
      end
      return false
    end
  
end
  


