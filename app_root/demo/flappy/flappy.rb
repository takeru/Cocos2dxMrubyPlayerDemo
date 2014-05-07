include Cocos2dx
fu = CCFileUtils.sharedFileUtils
fullpath_of_this_file = fu.fullPathForFilename(__FILE__)
fu.removeAllPaths
fu.purgeCachedEntries
fu.addSearchPath(fu.fullPathFromRelativeFile(".",     fullpath_of_this_file)) # current
fu.addSearchPath(fu.fullPathFromRelativeFile("../..", fullpath_of_this_file)) # for lib
Cocos2dxMrubyPlayer.load("lib/cocos2dx_support.rb")
wsurl = "ws://192.168.0.6:9292"
puts "connecting to: #{wsurl}"
Cocos2dx::Logger.add(Cocos2dx::WebSocketLogger.new(wsurl))
log "SearchPaths: #{fu.getSearchPaths.inspect}"

Cocos2dxMrubyPlayer.load("bird.rb")
Cocos2dxMrubyPlayer.load("wall.rb")

class FlappyApp
  attr_reader :scene
  def initialize
    log "FlappyApp#initialize"
    @win_size = CCDirector.sharedDirector.getWinSize
    log "@win_size=#{@win_size}"
  end

  def _create_scene
    @bird  = Bird.new
    log "@bird.getContentSize=#{@bird.getContentSize}"

    @wall  = Wall.new(true)
    log "@wall.getContentSize=#{@wall.getContentSize}"

    @layer = Layer.new
    @layer.addChild(@bird)
    @layer.addChild(@wall)
    @layer.addChild(@wall.lower_wall)

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
  end

  def start
    @layer.scheduleUpdateWithPriorityLua(1) do |dt,node|
      update(dt)
    end
  end

  def onTouchBegan(touch)
    unless @started
      start
      @started = true
    end

    @bird.up
    return true
  end

  def onTouchEnd(touch)
  end

  def update(dt)
    @bird.update(dt)
    if @wall.update(dt)
      @bird.levelup
    end
    if @bird.y < 0 || FlappyApp.height < @bird.y || @wall.hit?(@bird)
      reboot!
    end
  end

  def width
    @win_size.width
  end

  def height
    @win_size.height
  end

  @@instance = nil
  def self.instance
    @@instance ||= self.new
  end
  def self.method_missing(method,*args,&block)
    instance.__send__(method,*args,&block)
  end
end

begin
  d = Cocos2dx::CCDirector.sharedDirector
  view = Cocos2dx::CCEGLView.sharedOpenGLView
  frame_size = view.getFrameSize
  view.setDesignResolutionSize(frame_size.width, frame_size.height, Cocos2dx::KResolutionExactFit)
  d.setDisplayStats(true)
  app = FlappyApp.instance
  app._create_scene
  d.pushScene(app.scene.cc_object)
rescue => e
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end
