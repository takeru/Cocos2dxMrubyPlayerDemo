include Cocos2dx
fu = CCFileUtils.sharedFileUtils
fu.addSearchPath(fu.fullPathFromRelativeFile("", __FILE__))
fu.addSearchPath("")
#puts "SearchPaths:#{fu.getSearchPaths}"
Cocos2dxMrubyPlayer.load("../../lib/cocos2dx_support.rb")
#Cocos2dx::Logger.add(Cocos2dx::WebSocketLogger.new("ws://192.168.0.6:9292"))
fu.addSearchPath(fu.fullPathFromRelativeFile("resources", fu.fullPathForFilename(__FILE__)))

class WsApp
  attr_reader :scene
  def initialize
    _create_scene
    @touch_count = 0
    @handle = (1000 + rand(9000)).to_s

    @sound_and_icons = [
      ["blip2.mp3",  "block-blue-hd.png"],
      ["bomb.mp3",   "block-green-hd.png"],
      ["coin07.mp3", "block-red-hd.png"],
      ["jump01.mp3", "block-yellow-hd.png"],
      ["laser3.mp3", "Icon-57.png"]
    ]
    @my_index = rand(@sound_and_icons.size) 
  end

  def _create_scene
    @win_size = CCDirector.sharedDirector.getWinSize

    @layer = Layer.new

    _setup_touch
    @layer.addChild(_create_reboot_menu)

    @scene = Scene.new
    @scene.addChild(@layer)

    log_layer = LogLayer.new
    @scene.addChild(log_layer)
    Logger.add(log_layer)

    _setup_websocket

    nil
  end

  def _setup_touch
    @layer.registerScriptTouchHandler do |eventType, touch|
      case eventType
      when CCTOUCHBEGAN
        onTouchBegan(touch)
      when CCTOUCHMOVED
        onTouchMoved(touch)
      when CCTOUCHENDED
        onTouchEnded(touch)
      when CCTOUCHCANCELLED
        onTouchCanceled(touch)
      else
        raise "unknown eventType=#{eventType}"
      end
    end
    @layer.setTouchMode(KCCTouchesOneByOne)
    @layer.setTouchEnabled(true)
  end

  def _create_reboot_menu
    menu = Menu.new
    menu.setPosition(0,0)
    item = MenuItemFont.new("reboot!")
    item.setAnchorPoint(ccp(0,0))
    item.setPosition(ccp(@win_size.width-100,@win_size.height-30))
    item.registerScriptTapHandler do
      @ws.close if @ws
      reboot!
      log "*** reboot! ***"
    end
    menu.addChild(item)
    menu
  end

  def _setup_websocket
    ws_url = "ws://infinite-shelf-9645.herokuapp.com/?room=demo_websocket"
    # ws_url = "ws://echo.websocket.org"
    ws = WebSocket.create(ws_url) do |event,data|
      case event
      when 'open'
        log "**** open ****"
        @ws = ws
      when 'message'
        begin
          obj = JSON.parse(data)
          if obj['tap']
            sound, icon = @sound_and_icons[obj['tap']['index']]
            sprite = Sprite.new(icon)
            sprite.setPosition(obj['tap']['x'], obj['tap']['y'])
            @layer.addChild(sprite)
            CocosDenshion::SimpleAudioEngine.sharedEngine.playEffect(sound)
            log("RTT=#{sprintf('%5.3f', Time.now.to_f - obj['tap']['time'])}")
          end
        rescue => e
          log "event=message e=#{e.inspect}"
        end
      when 'close'
        log "**** close ****"
        @ws = nil
      else
        log "**** #{event} ****"
      end
    end
  end

  def onTouchBegan(touch)
    point = @layer.convertTouchToNodeSpace(touch)
    log("onTouchBegan: #{point.x.to_i},#{point.y.to_i}")

    name = ["Icon-57.png","Icon-72.png","Icon-114.png","Icon-144.png"].sample
    if @ws
      @ws.send(JSON::stringify({handle: @handle,
                                text:"TAP(#{point.x.to_i},#{point.y.to_i})",
                                tap:{
                                  x:point.x.to_i,
                                  y:point.y.to_i,
                                  index:@my_index,
                                  time:Time.now.to_f
                                }
                                }))
    end

    return true
  end

  def onTouchMoved(touch)
    #point = @layer.convertTouchToNodeSpace(touch)
    #log("onTouchMoved: #{point.x},#{point.y}")
  end

  def onTouchEnded(touch)
    #point = @layer.convertTouchToNodeSpace(touch)
    #log("onTouchEnded: #{point.x.to_i},#{point.y.to_i}")
    @touch_count += 1
    log "@touch_count = #{@touch_count}"
  end
end


d = CCDirector.sharedDirector
view = CCEGLView.sharedOpenGLView
frame_size = view.getFrameSize
view.setDesignResolutionSize(frame_size.width, frame_size.height, KResolutionExactFit)
d.setDisplayStats(false)
app = WsApp.new
d.pushScene(app.scene.cc_object)
