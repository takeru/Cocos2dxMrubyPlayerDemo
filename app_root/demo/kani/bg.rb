class Bg < Sprite
  def initialize(file, x, speed)
    @cc_class_name = 'CCSprite'
    super(file)

    @speed = speed
    @x     = x

    self.setAnchorPoint(ccp(0,0))
    self.setPosition(@x, 0)
  end

  def _update(dt)
    @x -= @speed * RATE * dt
    @x += 568*2 if @x < -568
    setPosition(@x, 0)
  end
end
