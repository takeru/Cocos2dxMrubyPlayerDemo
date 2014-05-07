class Bird < Sprite
  attr_reader :y
  def initialize
    @cc_class_name = 'CCSprite'
    super("images/bird.png")

    @easy = 15
    @x  = FlappyApp.width * 0.2
    @y  = FlappyApp.height / 2
    @vy = 0
    update(0)
  end

  def up
    @vy = 1500 / @easy
  end

  def update(dt)
    @vy += -6000 * dt / @easy
    @y += @vy * dt
    setPosition(@x,@y)
  end

  def levelup
    @easy *= 0.9
  end
end
