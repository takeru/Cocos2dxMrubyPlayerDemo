class DrawNodeApp
  attr_reader :scene
  def initialize
    _create_scene
  end

  def _create_scene
    @win_size = Cocos2d::CCDirector.sharedDirector.getWinSize

    @layer = Layer.new
    @layer.registerScriptTouchHandler do |eventType, touch|
      case eventType
      when Cocos2d::CCTOUCHBEGAN
        onTouchBegan(touch)
      when Cocos2d::CCTOUCHMOVED
        onTouchMoved(touch)
      when Cocos2d::CCTOUCHENDED
        onTouchEnded(touch)
      when Cocos2d::CCTOUCHCANCELLED
        onTouchCanceled(touch)
      else
        raise "unknown eventType=#{eventType} touch=#{touch}"
      end
    end
    @layer.setTouchMode(Cocos2d::KCCTouchesOneByOne)
    @layer.setTouchEnabled(true)

    @nodes = []

    # circles
    5.times do |n|
      dot = DrawNode.new
      dot.drawDot(Cocos2d::ccp(@win_size.width*rand, @win_size.height*rand), 200*rand, Cocos2d::ccc4f(rand, rand, rand, 0.7+0.3*rand))
      @nodes << dot
    end

    # lines
    5.times do |n|
      segment = DrawNode.new
      segment.drawSegment(Cocos2d::ccp(@win_size.width*rand, @win_size.height*rand),
                          Cocos2d::ccp(@win_size.width*rand, @win_size.height*rand),
                          20*rand,
                          Cocos2d::ccc4f(rand, rand, rand, 0.7+0.3*rand))
      @nodes << segment
    end

    # polygons
    5.times do |n|
      polygon = DrawNode.new
      points = []
      [3,4,5,6].sample.times do
        points << Cocos2d::ccp(@win_size.width*rand, @win_size.height*rand)
      end
      polygon.drawPolygon(points,
                          Cocos2d::ccc4f(rand, rand, rand, 0.7+0.3*rand),
                          10*rand,
                          Cocos2d::ccc4f(rand, rand, rand, 0.7+0.3*rand)
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
      Cocos2dx.reboot!
    end
  end
end

begin
  d = Cocos2d::CCDirector.sharedDirector
  view = Cocos2d::CCEGLView.sharedOpenGLView
  frame_size = view.getFrameSize
  view.setDesignResolutionSize(frame_size.width, frame_size.height, Cocos2d::KResolutionExactFit)
  d.setDisplayStats(true)
  app = DrawNodeApp.new
  d.pushScene(app.scene.cc_object)
rescue => e
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end
