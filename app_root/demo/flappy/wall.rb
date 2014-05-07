begin
class Wall < DrawNode
  def initialize
    @cc_class_name = 'CCDrawNode'
    super

    @vx     = -200
    @x = FlappyApp.width
    @y = FlappyApp.height/2

    [-1, 1].each do |z|
      dy = z * (320+150)
      _draw_rect(
        0, 0+dy,
        100, 640,
        0.0, 0.8, 0.0, 1.0,
        3,
        0.0, 0.6, 0.0, 1.0
      )
      _draw_rect(
        0, 0+dy-z*320,
        130, 40,
        0.0, 0.8, 0.0, 1.0,
        3,
        0.0, 0.6, 0.0, 1.0
      )
    end
    update(0)
  end

  def _draw_rect(x, y, w, h, r0, g0, b0, a0, border, r1, g1, b1, a1)
    points = [
      ccp(-w/2+x, -h/2+y),
      ccp( w/2+x, -h/2+y),
      ccp( w/2+x,  h/2+y),
      ccp(-w/2+x,  h/2+y)
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
    setPosition(@x,@y)
  end
end
rescue => e
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end
