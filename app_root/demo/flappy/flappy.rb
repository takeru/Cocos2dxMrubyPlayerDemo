include Cocos2dx
fu = CCFileUtils.sharedFileUtils
fu.addSearchPath(fu.fullPathFromRelativeFile("../..", __FILE__))
fu.addSearchPath(fu.fullPathFromRelativeFile(".",     __FILE__))
Cocos2dxMrubyPlayer.load("lib/cocos2dx_support.rb")
wsurl = "ws://192.168.0.7:9292"
puts "connecting to: #{wsurl}"
Cocos2dx::Logger.add(Cocos2dx::WebSocketLogger.new(wsurl))
log "SearchPaths: #{fu.getSearchPaths.inspect}"

Cocos2dxMrubyPlayer.load("bird.rb")
class FlappyApp
  attr_reader :scene
  def initialize
    log "FlappyApp#initialize"
    @win_size = CCDirector.sharedDirector.getWinSize
    log "@win_size=#{@win_size}"

    @bird  = Bird.new
    @bird.setPosition(@win_size.width/2, @win_size.height/2)
    @vy = 0
    log "@bird.getContentSize=#{@bird.getContentSize}"

    @layer = Layer.new
    @layer.addChild(@bird)

    @scene = Scene.new
    @scene.addChild(@layer)

    @layer.registerScriptTouchHandler do |eventType, touch|
      case eventType
      when CCTOUCHBEGAN
        onTouchBegan(touch)
      when CCTOUCHENDED
        onTouchEnd(touch)
      end
    end
    @layer.setTouchMode(KCCTouchesOneByOne)
    @layer.setTouchEnabled(true)

    @layer.scheduleUpdateWithPriorityLua(1) do |dt,node|
      update(dt)
    end
  end

  def onTouchBegan(touch)
    log "touch"
    @vy = 1500
    return true
  end

  def onTouchEnd(touch)
  end

  def update(dt)
    @vy -= 100
    pos = @bird.getPosition
    pos.y += @vy * dt
    if pos.y < 0
      pos.y = 0
      @vy = 0
    end
    if 640 < pos.y
      pos.y = 640
      @vy = 0
    end
    @bird.setPosition(pos)
  end
end

begin
  d = Cocos2dx::CCDirector.sharedDirector
  view = Cocos2dx::CCEGLView.sharedOpenGLView
  frame_size = view.getFrameSize
  view.setDesignResolutionSize(frame_size.width, frame_size.height, Cocos2dx::KResolutionExactFit)
  d.setDisplayStats(true)
  app = FlappyApp.new
  d.pushScene(app.scene.cc_object)
rescue => e
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end
