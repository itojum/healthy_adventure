require './class/enemy.rb'
class Radish < Enemy
   

  def initialize(x, y)
    image = Image.load("./image/enemy/Radish.png")
    super(x, y, image)

    self.scale_x = 0.4
    self.scale_y = 0.4
    width = self.image.height
    height = self.image.height
    self.collision = [width * 0.1, height * 0.2, width * 0.5, height]

    @bullet_image = Image.load("./image/bullet/bullet_enemy1.png")
    @jump = -20
    @score = 10
  end
  def move
    @dx = -1 + @facing * 3
    @dy = 0

  
    

    if @jump == -20 && @isGround && rand(0..50) == 0
      @jump = 21
  end

    if @jump > -20
        @jump -= 1
    end
    @dy -= @jump
  end

  
  end