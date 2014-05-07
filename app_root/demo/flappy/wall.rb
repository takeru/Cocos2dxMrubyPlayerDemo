begin
class Wall < DrawNode
  attr_reader :lower_wall
  def initialize(upper)
    @cc_class_name = 'CCDrawNode'
    super()

    @upper = upper
    @vx     = -200
    @x = FlappyApp.width
    @y = FlappyApp.height/2
    @width  = 100
    @height = 400
    @hole   = 300

    @dy = (@height/2+@hole/2)
    if upper
      @lower_wall = Wall.new(false)
    else
      @dy *= -1
    end

    setContentSize(CCSize.new(@width, @height))
    setAnchorPoint(CCPoint.new(0.5,0.5))

    _draw_rect(
      0, 0,
      @width, @height,
      0.0, 0.8, 0.0, 1.0,
      3,
      0.0, 0.6, 0.0, 1.0
    )
    _draw_rect(
      -10, @height-10,
      @width+20, 20,
      0.0, 0.8, 0.0, 1.0/2,
      3,
      0.0, 0.6, 0.0, 1.0/2
    )
    _draw_rect(
      -10, -10,
      @width+20, 20,
      0.0, 0.8, 0.0, 1.0/2,
      3,
      0.0, 0.6, 0.0, 1.0/2
    )
    update(0)
  end

  def _draw_rect(x, y, w, h, r0, g0, b0, a0, border, r1, g1, b1, a1)
    points = [
      ccp(x  , y  ),
      ccp(x+w, y  ),
      ccp(x+w, y+h),
      ccp(x  , y+h)
    ]
    drawPolygon(points,
      ccc4f(r0, g0, b0, a0),
      border,
      ccc4f(r1, g1, b1, a1)
    )
  end

  def update(dt)
    @x += @vx * dt
    if @x < 0
      @x = FlappyApp.width
      @y = (rand*2-1) * 150 + FlappyApp.height/2
    end
    setPosition(@x,@y+@dy)
    @lower_wall.setPosition(@x,@y-@dy) if @lower_wall
  end

  def hit?(bird)
    bb = bird.boundingBox
    if bb.intersectsRect(boundingBox)
      return true
    end
    if @lower_wall && bb.intersectsRect(@lower_wall.boundingBox)
      return true
    end
    return false
  end
end
rescue => e
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end
