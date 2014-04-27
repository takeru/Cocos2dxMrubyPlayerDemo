class Dot < DrawNode
  def initialize(x, y, radius, r, g, b, a)
    @cc_class_name = 'CCDrawNode'
    super()
    self.drawDot(ccp(0, 0), radius, ccc4f(r, g, b, a))
    @x  = x
    @y  = y
    @vx = r*2-1
    @vy = g*2-1
  end
  def update(dt)
    @x += @vx
    @y += @vy
    setPosition(@x, @y)
  end
end

class UpdateApp
  attr_reader :scene
  def initialize
    _create_scene
  end

  def _create_scene
    @win_size = CCDirector.sharedDirector.getWinSize

    @layer = Layer.new

    @nodes = []
    600.times do |n|
      dot = Dot.new(
        @win_size.width  * 0.5,
        @win_size.height * 0.5,
        10,
        rand, rand, rand, 0.7+0.3*rand
      )
      @nodes << dot
      @layer.addChild(dot)
    end

    @scene = Scene.new
    @scene.addChild(@layer)

    @scene.scheduleUpdateWithPriorityLua(1) do |dt,node|
      self.update(dt)
    end

    nil
  end

  def update(dt)
    @nodes.each do |n|
      n.update(dt)
    end

    @nodes.pop.removeFromParentAndCleanup(true)
    if @nodes.size == 0
      Cocos2dx.reboot!
    end
  end
end

begin
  d = CCDirector.sharedDirector
  view = CCEGLView.sharedOpenGLView
  frame_size = view.getFrameSize
  view.setDesignResolutionSize(frame_size.width, frame_size.height, KResolutionExactFit)
  d.setDisplayStats(true)
  app = UpdateApp.new
  d.pushScene(app.scene.cc_object)
rescue => e
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end
