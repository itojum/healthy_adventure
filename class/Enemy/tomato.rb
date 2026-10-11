require './class/enemy.rb'
class Tomato < Enemy
  def initialize(x, y)
    self.image = Image.load("./image/enemy/tomato.png")
    super(x, y, image)
    self.scale_x = 0.4
    self.scale_y = 0.4
    width = self.image.height
    height = self.image.height
    self.collision = [width * 0.1, height * 0.2, width * 0.5, height]

    @bullet_image = Image.load("./image/bullet/tomato_bullet.png")
    @jump = -20
    @goal_move = 200
    @now_move = 0
    @score = 20
  end
  def move
    if @facing == 1
      self.scale_x = -0.4
    else
      self.scale_x = 0.4
    end

    @dx = -1 + @facing * 3
    @dy = 0

    @now_move += 1
    if @now_move > @goal_move 
      @facing *= -1
      @now_move = 0
    end
    
  end
end