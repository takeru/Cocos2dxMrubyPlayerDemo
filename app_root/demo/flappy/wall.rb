begin
class Wall < DrawNode
  def initialize
    @cc_class_name = 'CCDrawNode'
    super

    @vx     = -100
    @width  =   50
    @height =  200
    _draw

    setPosition(FlappyApp.width-200, FlappyApp.height/2)
  end

  def _draw
    points = [
      ccp(-@width/2, -@height/2),
      ccp( @width/2, -@height/2),
      ccp( @width/2,  @height/2),
      ccp(-@width/2,  @height/2)
    ]
    r0, g0, b0, a0 = 0.0, 0.8, 0.0, 1.0
    r1, g1, b1, a1 = 0.0, 0.6, 0.0, 1.0
    border = 2
    drawPolygon(points,
      ccc4f(r0, g0, b0, a0),
      border,
      ccc4f(r1, g1, b1, a1)
    )
  end

  def update(dt)
    pos = getPosition
    pos.x += @vx * dt
    setPosition(pos)
  end
end
rescue => e
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end
