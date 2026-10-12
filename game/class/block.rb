$blockImage = Image.load_tiles('./image/block.png', 6, 1)

class Block < Sprite
  def initialize(x, y, blockIndex)
    self.image = $blockImage[blockIndex]
    
    self.x = x * 64 - 50
    self.y = 480 - y * 64
    self.scale_x = 0.5
    self.scale_y = 0.5
  end

  def update
    self.x -= 1
  end
  def checkOutside
    return self.x < -128
  end

end