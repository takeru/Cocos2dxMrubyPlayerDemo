class TouchApp
  attr_reader :scene
  def initialize
    @touch_count = 0

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

    @scene = Scene.new
    @scene.addChild(@layer)

    nil
  end

  def onTouchBegan(touch)
    point = @layer.convertTouchToNodeSpace(touch)
    log("onTouchBegan: #{point.x},#{point.y}")

    name = ["Icon-57.png","Icon-72.png","Icon-114.png","Icon-144.png"].sample
    @sprite = Sprite.new(name)
    @sprite.setPosition(point.x, point.y)
    @layer.addChild(@sprite)

    return true
  end

  def onTouchMoved(touch)
    point = @layer.convertTouchToNodeSpace(touch)
    log("onTouchMoved: #{point.x},#{point.y}")

    @sprite.setPosition(point.x, point.y)
  end

  def onTouchEnded(touch)
    point = @layer.convertTouchToNodeSpace(touch)
    log("onTouchEnded: #{point.x},#{point.y}")

    @touch_count += 1
    log "@touch_count = #{@touch_count}"
    if 10 < @touch_count
      Cocos2dx.reboot!
    end
  end

  def onTouchCanceled(touch)
    onTouchEnded(touch)
  end
end

begin
  d = Cocos2d::CCDirector.sharedDirector
  view = Cocos2d::CCEGLView.sharedOpenGLView
  frame_size = view.getFrameSize
  view.setDesignResolutionSize(frame_size.width, frame_size.height, Cocos2d::KResolutionExactFit)
  d.setDisplayStats(true)
  app = TouchApp.new
  d.pushScene(app.scene.cc_object)
rescue => e
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end
