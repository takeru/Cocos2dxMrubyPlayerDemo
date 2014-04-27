class ExtApp
  attr_reader :scene
  def initialize
    @win_size = CCDirector.sharedDirector.getWinSize
    @scene = Scene.new

    @layer = Layer.new
#                     [STATIC, 'CCLabelTTF*', 'create', ['const char*', 'const char*', 'float']],



    swipe_recognizer = CCSwipeGestureRecognizerForScript.create
    swipe_recognizer.setDirection(
      KSwipeGestureRecognizerDirectionRight |
      KSwipeGestureRecognizerDirectionLeft  |
      KSwipeGestureRecognizerDirectionUp    |
      KSwipeGestureRecognizerDirectionDown
    )
    swipe_recognizer.setHandler do |swipe|
      log "**** swipe! direction=#{swipe.direction} location=(#{swipe.location.x},#{swipe.location.y})****"
    end
    @scene.addChild(swipe_recognizer)
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
