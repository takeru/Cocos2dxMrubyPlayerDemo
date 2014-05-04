class ExtApp
  attr_reader :scene
  def initialize
    @count = 0
    @win_size = CCDirector.sharedDirector.getWinSize
    @scene = Scene.new

    @scene.addChild(_create_swipe_recognizer)
    @scene.addChild(_create_pinch_recognizer)
    @scene.addChild(_create_reboot_menu)

    @log_layer = LogLayer.new(30)
    @scene.addChild(@log_layer)
    Logger.add(@log_layer)

    log "swipe or pinch"
  end

  def _create_swipe_recognizer
    swipe_recognizer = CCSwipeGestureRecognizerForScript.create
    swipe_recognizer.setDirection(
      KSwipeGestureRecognizerDirectionRight |
      KSwipeGestureRecognizerDirectionLeft  |
      KSwipeGestureRecognizerDirectionUp    |
      KSwipeGestureRecognizerDirectionDown
    )
    swipe_recognizer.setHandler do |swipe|
      log "swipe! #{@count} direction=#{swipe.direction} location=(#{swipe.location.x.floor},#{swipe.location.y.floor})"
      @count += 1
    end
    swipe_recognizer
  end

  def _create_pinch_recognizer
    pinch_recognizer = CCPinchGestureRecognizerForScript.create
    pinch_recognizer.setHandler do |pinch|
      log "pinch! #{@count} type=#{pinch.type}"
      @count += 1
    end
    pinch_recognizer
  end

  def _create_reboot_menu
    menu = Menu.new
    menu.setPosition(0,0)
    item = MenuItemFont.new("reboot!")
    item.setAnchorPoint(ccp(0,0))
    item.setPosition(ccp(@win_size.width-100,@win_size.height-30))
    item.registerScriptTapHandler do
      reboot!
      log "*** reboot! ***"
    end
    menu.addChild(item)
    menu
  end
end

begin
  d = CCDirector.sharedDirector
  view = CCEGLView.sharedOpenGLView
  frame_size = view.getFrameSize
  view.setDesignResolutionSize(frame_size.width, frame_size.height, KResolutionExactFit)
  d.setDisplayStats(true)
  app = ExtApp.new
  d.pushScene(app.scene.cc_object)
rescue => e
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end
