class DrawNodeApp
  attr_reader :scene
  def initialize
    _create_scene
  end

  def _create_scene
    @win_size = CCDirector.sharedDirector.getWinSize

    @layer = Layer.new
    @layer.registerScriptTouchHandler do |eventType, touch|
      case eventType
      when CCTOUCHBEGAN
        onTouchBegan(touch)
      when CCTOUCHMOVED
        onTouchMoved(touch)
      when CCTOUCHENDED
        onTouchEnded(touch)
      when CCTOUCHCANCELLED
        onTouchCanceled(touch)
      else
        raise "unknown eventType=#{eventType} touch=#{touch}"
      end
    end
    @layer.setTouchMode(KCCTouchesOneByOne)
    @layer.setTouchEnabled(true)

    @nodes = []

    # circles
    5.times do |n|
      dot = DrawNode.new
      dot.drawDot(ccp(@win_size.width*rand, @win_size.height*rand), 200*rand, ccc4f(rand, rand, rand, 0.7+0.3*rand))
      @nodes << dot
    end

    # lines
    5.times do |n|
      segment = DrawNode.new
      segment.drawSegment(ccp(@win_size.width*rand, @win_size.height*rand),
                          ccp(@win_size.width*rand, @win_size.height*rand),
                          20*rand,
                          ccc4f(rand, rand, rand, 0.7+0.3*rand))
      @nodes << segment
    end

    # polygons
    5.times do |n|
      polygon = DrawNode.new
      points = []
      [3,4,5,6].sample.times do
        points << ccp(@win_size.width*rand, @win_size.height*rand)
      end
      polygon.drawPolygon(points,
                          ccc4f(rand, rand, rand, 0.7+0.3*rand),
                          10*rand,
                          ccc4f(rand, rand, rand, 0.7+0.3*rand)
                          )
      @nodes << polygon
    end

    @nodes = @nodes.shuffle
    @nodes.each_with_index do |n, index|
      n.setZOrder(index)
      @layer.addChild(n)
    end

    @scene = Scene.new
    @scene.addChild(@layer)

    nil
  end

  def onTouchBegan(touch)
    return true
  end

  def onTouchMoved(touch)
  end

  def onTouchEnded(touch)
    @nodes.pop.removeFromParentAndCleanup(true)
    if @nodes.size == 0
      reboot!
    end
  end
end

begin
  d = CCDirector.sharedDirector
  view = CCEGLView.sharedOpenGLView
  frame_size = view.getFrameSize
  view.setDesignResolutionSize(frame_size.width, frame_size.height, KResolutionExactFit)
  d.setDisplayStats(true)
  app = DrawNodeApp.new
  d.pushScene(app.scene.cc_object)
rescue => e
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end
