class MultiTouchApp
  attr_reader :scene
  def initialize
    @touch_count = 0
    @sprites = []

    @win_size = CCDirector.sharedDirector.getWinSize

    @layer = Layer.new
    @layer.setTouchMode(KCCTouchesAllAtOnce)
    @layer.registerScriptTouchHandler(true) do |eventType, touches|
      case eventType
      when CCTOUCHBEGAN
        onTouchBegan(touches)
      when CCTOUCHMOVED
        onTouchMoved(touches)
      when CCTOUCHENDED
        onTouchEnded(touches)
      when CCTOUCHCANCELLED
        onTouchCanceled(touches)
      else
        raise "unknown eventType=#{eventType} touches=#{touches}"
      end
    end
    @layer.setTouchEnabled(true)

    @scene = Scene.new
    @scene.addChild(@layer)

    nil
  end

  def onTouchBegan(touches)
    log("onTouchBegan: touches.size=#{touches.size}")
    touches.each do |touch|
      point = @layer.convertTouchToNodeSpace(touch)
      log("onTouchBegan: #{touch.getID} (#{point.x.floor},#{point.y.floor})")

      name = ["Icon-57.png","Icon-72.png","Icon-114.png","Icon-144.png"].sample
      sprite = Sprite.new(name)
      sprite.setPosition(point.x, point.y)
      @layer.addChild(sprite)
      @sprites[touch.getID] = sprite
    end

    return true
  end

  def onTouchMoved(touches)
    log("onTouchMoved: touches.size=#{touches.size}")
    touches.each do |touch|
      point = @layer.convertTouchToNodeSpace(touch)
      log("onTouchMoved: #{touch.getID} (#{point.x.floor},#{point.y.floor})")
      @sprites[touch.getID].setPosition(point.x, point.y)
    end
  end

  def onTouchEnded(touches)
    log("onTouchEnded: touches.size=#{touches.size}")
    touches.each do |touch|
      point = @layer.convertTouchToNodeSpace(touch)
      log("onTouchEnded: #{touch.getID} (#{point.x.floor},#{point.y.floor})")
      @sprites[touch.getID] = nil
    end

    @touch_count += 1
    log "@touch_count = #{@touch_count}"
    if 10 < @touch_count
      Cocos2dx.reboot!
    end
  end

  def onTouchCanceled(touches)
    onTouchEnded(touches)
  end
end

begin
  d = CCDirector.sharedDirector
  view = CCEGLView.sharedOpenGLView
  frame_size = view.getFrameSize
  view.setDesignResolutionSize(frame_size.width, frame_size.height, KResolutionExactFit)
  d.setDisplayStats(true)
  app = MultiTouchApp.new
  d.pushScene(app.scene.cc_object)
rescue => e
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end
