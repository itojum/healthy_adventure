require './class/entity.rb'
require_relative './bullet'
class Player < Entity

    def initialize(x, y,chara_type)

        bullet_image = Image.load_tiles('./image/bullet/player_bullet.png', 3, 1)
        case chara_type
        when 1
            image = Image.load("./image/charactor.png")
        when 2
            image = Image.load("./image/charactor2.png")
        when 3
            image = Image.load("./image/charactor3.png")
        end
        

        super(x, y, image)

        @bullet_image = bullet_image[chara_type - 1]

        @cooltime = 0
        @facing=1
        @jump = -20
        self.scale_x = 0.2
        self.scale_y = 0.2

        width = self.image.width
        height = self.image.height
        self.collision = [width * 0.2, height * 0.1, width * 0.8, height]
    end

    def move
       @dx = -1
       @dy = 0

      @dx += Input.x*5 if self.x < 1024
      @facing=Input.x if Input.x != 0
    
      if @jump == -20 && @isGround && Input.y == -1
          @jump = 21
      end

      if @jump > -20
          @jump -= 1
      end
      @dy -= @jump

      if @facing == 1
        self.scale_x = -0.2
      else
        self.scale_x = 0.2
      end  

      @cooltime -= 1
    end

    def hit(enemys)
        enemys.each do |enemy|
            if self === enemy
                return true
            end
        end
        return false
    end

    def bullet ()
        @cooltime = 20
       return Bullet.new(self.x,self.y,self)
    end
    def cooltime
        @cooltime
    end
end