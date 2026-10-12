class Entity < Sprite

    def initialize(x, y, image)
        super(x, y, image)
        
        self.x = x * 64 - 50
        self.y = 512 - y * 64

        self.center_x = self.image.width / 2
        self.center_y = self.image.height / 2
        self.offset_sync = true

        @dx = 0
        @dy = 0

        @bullet_image = nil
        @jump = 0
        @facing = -1
        @isGround = false
    end

    def bullet_image
        @bullet_image
      end
    def facing
        @facing
    end
    
    def hitBlock(blocks)
        self.x += @dx

        blocks.each do |block|
            if self === block
                @facing *= -1
                self.x -= @dx

                while !(self === block)
                    self.x += @dx * 0.1
                end
                self.x -= @dx * 0.5
            end
        end

        self.y += @dy
        @isGround = false
        blocks.each do |block|
            if self === block
                @jump = 0 if @dy < 0
                self.y -= @dy
                @isGround = true
                while !(self === block)
                    self.y += @dy * 0.1
                end
                self.y -= @dy * 0.1
            end
        end
    end
    def outside
        return self.y > 700 || self.x < -250
    end
end
