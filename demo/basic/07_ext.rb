class ExtApp
  attr_reader :scene
  def initialize
    @win_size = CCDirector.sharedDirector.getWinSize
    @scene = Scene.new

    @scene.addChild(_create_swipe_recognizer)

    @log_layer = LogLayer.new(30)
    @scene.addChild(@log_layer)
    Logger.add(@log_layer)

    log "swipe!"
  end

  def _create_swipe_recognizer
    swipe_recognizer = CCSwipeGestureRecognizerForScript.create
    swipe_recognizer.setDirection(
      KSwipeGestureRecognizerDirectionRight |
      KSwipeGestureRecognizerDirectionLeft  |
      KSwipeGestureRecognizerDirectionUp    |
      KSwipeGestureRecognizerDirectionDown
    )
    @count = 10
    swipe_recognizer.setHandler do |swipe|
      log "swipe! #{@count} direction=#{swipe.direction} location=(#{swipe.location.x.floor},#{swipe.location.y.floor})"
      @count -= 1
      if @count < 0
        reboot!
      end
    end
    swipe_recognizer
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
