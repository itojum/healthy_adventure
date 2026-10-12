require './class/enemy.rb'
class Carrot < Enemy
  def initialize(x, y)
    image = Image.load("./image/enemy/carrot.png")
    super(x, y, image)
    self.scale_x = 0.2
    self.scale_y = 0.2
    width = self.image.height
    height = self.image.height
    self.collision = [width * 0.1, height * 0.2, width * 0.5, height]

    @bullet_image = Image.load("./image/bullet/bullet_enemy1.png")
    @jump = -15
    @score = 15
  end
  def move
    @dx = -1 + @facing * 3
    @dy = 0

    if @jump == -15 && @isGround && rand(0..30) == 0
        @jump = 16
    end

    if @jump > -15
        @jump -= 1
    end
    @dy -= @jump
  end
end