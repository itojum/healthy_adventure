require './class/enemy.rb'
class Fire < Enemy
  def initialize(x, y, angle = 0)
    image = Image.load("./image/enemy/fire.png")
    super(x, y, image)
    self.y += 10
    self.angle=angle
    self.scale_x = 0.2
    self.scale_y = 0.2
    width = self.image.height
    height = self.image.height
    self.collision = [width * 0.4, height * 0.4, width * 0.6, height]

    @invincible = true
  end
  
  def move
    self.x -= 1
  end
  
  def bullet ()
    return nil
 end

end
