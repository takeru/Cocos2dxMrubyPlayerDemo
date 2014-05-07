class Bird < Sprite
  def initialize
    @cc_class_name = 'CCSprite'
    super("images/bird.png")
    @vy = 0
    setPosition(FlappyApp.width/2, FlappyApp.height/2)
  end

  def up
    @vy = 1500
  end

  def update(dt)
    @vy -= 100
    pos = getPosition
    pos.y += @vy * dt
    if pos.y < 0
      pos.y = 0
      @vy = 0
    end
    if 640 < pos.y
      pos.y = 640
      @vy = 0
    end
    setPosition(pos)
  end
end
