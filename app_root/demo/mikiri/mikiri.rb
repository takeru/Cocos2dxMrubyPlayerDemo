include Cocos2dx
fu = CCFileUtils.sharedFileUtils
fullpath_of_this_file = fu.fullPathForFilename(__FILE__)
fu.removeAllPaths
fu.purgeCachedEntries
fu.addSearchPath(fu.fullPathFromRelativeFile(".",     fullpath_of_this_file)) # current
fu.addSearchPath(fu.fullPathFromRelativeFile("../..", fullpath_of_this_file)) # for lib
#Cocos2dxMrubyPlayer.load("lib/cocos2dx_support.rb")
#wsurl = "ws://192.168.0.6:9292"
#puts "connecting to: #{wsurl}"
#Cocos2dx::Logger.add(Cocos2dx::WebSocketLogger.new(wsurl))
log "SearchPaths: #{fu.getSearchPaths.inspect}"

#Cocos2dxMrubyPlayer.load("xxx.rb")

class MikiriApp
  attr_reader :scene
  def initialize
    @win_size = CCDirector.sharedDirector.getWinSize
    log "@win_size=#{@win_size}"

    @state = nil
    @best_time = CCUserDefault.sharedUserDefault.getFloatForKey("mikiri#best_time", 1000)
    if 999 < @best_time
      @best_time = nil
    end
    @try_count = CCUserDefault.sharedUserDefault.getIntegerForKey("mikiri#try_count", 0)
  end

  def _create_scene
    @layer = Layer.new

    @time_label = LabelTTF.new("", "Marker Felt", 200)
    @time_label.setPosition(@win_size.width/2, @win_size.height*0.50)
    @layer.addChild(@time_label)

    @scene = Scene.new
    @scene.addChild(@layer)

    _add_reboot_menu
    _add_activity_label

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

    ws_init
  end

  def _add_reboot_menu
    menu = Menu.new
    menu.setPosition(0,0)
    item = MenuItemFont.new("reboot!")
    item.setFontSizeObj(50)
    item.setAnchorPoint(ccp(1,1))
    item.setPosition(@win_size.width,@win_size.height)
    item.registerScriptTapHandler do
      reboot!
      log "*** reboot! ***"
    end
    menu.addChild(item)
    @layer.addChild(menu)
  end

  def _add_activity_label
    @activity_logs = []
    @font_height = 30
    @logs_max = (@win_size.height / @font_height).floor
    @activity_label = LabelTTF.new("", 'Marker Felt', @font_height, CCSize.new(@win_size.width,@win_size.height), KCCTextAlignmentLeft, KCCVerticalTextAlignmentBottom)
    @activity_label.setAnchorPoint(ccp(0,0))
    @activity_label.setPosition(0,0)
    @layer.addChild(@activity_label)
  end

  def ws_init
    account = Cocos2dxMrubyPlayer::DropBox.account
    if account
      @handle = account[:display_name]
    else
      @handle = "anon"+(1000 + rand(9000)).to_s
    end

    ws_url = "ws://infinite-shelf-9645.herokuapp.com/?room=mikiri"
    @ws = WebSocket.create(ws_url) do |event,data|
      log "ws event=#{event} data=#{data}"
      begin
        case event
        when "open"
          ws_send('text'=>'hello!')
          reset
        when "message"
          obj = JSON.parse(data)
          activity_log(obj['handle'] + " : " + obj['text'])
          if obj['time'] && obj['time'].to_f < 0.3
            CocosDenshion::SimpleAudioEngine.sharedEngine.playEffect('laser3.mp3')
          end
        when "close"
          @ws = nil
          activity_log("close")
        when "error"
          activity_log("error")
        end
      rescue => e
        log "Error in websocket callback: event=#{event} e=#{e.inspect}"
      end
    end
  end

  def ws_send(data)
    data['text'] ||= data.inspect
    data['handle'] = @handle + "(#{@try_count})"
    @ws.send(JSON::stringify(data)) if @ws
  end

  def activity_log(s)
    @activity_logs.push(s)
    @activity_logs.shift if @logs_max < @activity_logs.size
    @activity_label.setString(@activity_logs.join("\n"))
  end

  def reset
    @try_count = CCUserDefault.sharedUserDefault.getIntegerForKey("mikiri#try_count", 0)
    @try_count += 1
    CCUserDefault.sharedUserDefault.setIntegerForKey("mikiri#try_count", @try_count)

    ws_send('text'=>'start!')

    # state : wait -> start -> stop
    #              -> fail
    @state = :wait
    @start_time = nil
    @stop_time  = nil
    @time_label.setString("")
    @start_counter = 100 + (rand * 600).to_i
  end

  def onTouchBegan(touch)
    case @state
    when :wait
      @state = :fail
      @stop_time = Time.now
      CocosDenshion::SimpleAudioEngine.sharedEngine.playEffect("blip2.mp3")

      ws_send('text'=>"fail!")
    when :start
      @state = :stop
      @stop_time = Time.now
      CocosDenshion::SimpleAudioEngine.sharedEngine.playEffect("coin07.mp3")

      dt = @stop_time - @start_time
      _update_best_time(dt)
      time = sprintf("%5.3f", dt)
      text = "#{time} (best=#{sprintf("%5.3f", @best_time)})"
      ws_send('text'=>text, 'time'=>time)
    when :stop, :fail
      reset
    end
  end

  def update(dt)
    case @state
    when :wait
      @start_counter -= 1
      if @start_counter < 0
        @state = :start
        @start_time = Time.now
      end
    when :start
      dt = Time.now - @start_time
      @time_label.setString(sprintf("%5.3f", dt))
    when :stop
      dt = @stop_time - @start_time
      @time_label.setString(sprintf("%5.3f", dt))
    when :fail
      @time_label.setString("fail!")
    end
  end

  def _update_best_time(dt)
    @best_time = CCUserDefault.sharedUserDefault.getFloatForKey("mikiri#best_time", 99999.0)
    if dt < @best_time
      @best_time = dt
      CCUserDefault.sharedUserDefault.setFloatForKey("mikiri#best_time", @best_time)
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
 #d.setDisplayStats(true)
  app = MikiriApp.instance
  app._create_scene
  d.pushScene(app.scene.cc_object)
rescue => e
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end
