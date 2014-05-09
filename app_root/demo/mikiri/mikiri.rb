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

#Cocos2dxMrubyPlayer.load("xxx.rb")

class MikiriApp
  attr_reader :scene
  def initialize
    @win_size = CCDirector.sharedDirector.getWinSize
    log "@win_size=#{@win_size}"
  end

  def _create_scene
    @layer = Layer.new

    @time_label = LabelTTF.new("", "Marker Felt", 200)
    @time_label.setPosition(@win_size.width/2, @win_size.height*0.50)
    @layer.addChild(@time_label)

    @scene = Scene.new
    @scene.addChild(@layer)

    _add_reboot_menu

    @layer.registerScriptTouchHandler do |eventType, touch|
      case eventType
      when CCTOUCHBEGAN
        onTouchBegan(touch)
      end
    end
    @layer.setTouchMode(KCCTouchesOneByOne)
    @layer.setTouchEnabled(true)

    @layer.scheduleUpdateWithPriorityLua(1) do |dt,node|
      update(dt)
    end

    reset
  end

  def _add_reboot_menu
    menu = Menu.new
    menu.setPosition(0,0)
    item = MenuItemFont.new("reboot!")
    item.setFontSizeObj(50)
    item.setAnchorPoint(ccp(0,1))
    item.setPosition(ccp(0,@win_size.height))
    item.registerScriptTapHandler do
      reboot!
      log "*** reboot! ***"
    end
    menu.addChild(item)
    @layer.addChild(menu)
  end

  def reset
    @start_time = nil
    @stop_time  = nil
    @time_label.setString("")
    @start_counter = (rand * 600).to_i
  end

  def onTouchBegan(touch)
    if @start_time
      if @stop_time.nil?
        @stop_time = Time.now
        CocosDenshion::SimpleAudioEngine.sharedEngine.playEffect("coin07.mp3")
      else
        reset
      end
    else
      CocosDenshion::SimpleAudioEngine.sharedEngine.playEffect("blip2.mp3")
      reboot!
    end
  end

  def update(dt)
    @start_counter -= 1
    if @start_time.nil? && @start_counter < 0
      @start_time = Time.now
    end

    if @start_time
      dt = (@stop_time || Time.now) - @start_time
      @time_label.setString(sprintf("%5.3f", dt))
    end
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
  app = MikiriApp.instance
  app._create_scene
  d.pushScene(app.scene.cc_object)
rescue => e
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end
