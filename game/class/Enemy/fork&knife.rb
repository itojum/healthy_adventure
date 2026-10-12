require './class/enemy.rb'
class ForkKnife < Enemy
  def initialize(x, y, angle = 0)
    image = Image.load_tiles('./image/enemy/fork&knife.png', 2, 1)[rand(0..1)]
    super(x, y, image)
    self.angle=angle
    self.y += 32

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