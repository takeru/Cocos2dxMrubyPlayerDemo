class Bird < Sprite
  def initialize
    @cc_class_name = 'CCSprite'
    super("images/bird.png")

    @easy = 5
    @vy = 0
    setPosition(FlappyApp.width/2, FlappyApp.height/2)
  end

  def up
    @vy = 1500/@easy
  end

  def update(dt)
    @vy -= 100/@easy
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
