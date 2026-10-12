class Goal < Sprite
  def initialize(x, y)
    super(x, y)
        
    self.x = x * 64 - 50
    self.y = 320 - y * 64
    self.image = Image.load("./image/goal.png")
    
    self.scale_x = 0.4
    self.scale_y = 0.4

    width = self.image.width
    height = self.image.height
    self.collision = [width * 0.2, height * 0.1, width * 0.8, height]
  end

  def goal(player)
    self.x -= 1
    return self === player
  end
end