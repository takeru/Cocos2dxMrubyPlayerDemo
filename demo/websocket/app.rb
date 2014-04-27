$resources_path = Cocos2dxMrubyPlayer.root_path + "demo/websocket/resources/"

class WsApp
  attr_reader :scene
  def initialize
    _create_scene
    @touch_count = 0
    @handle = (1000 + rand(9000)).to_s

    @sound_and_icons = [
      [$resources_path + "blip2.mp3",  $resources_path + "block-blue-hd.png"],
      [$resources_path + "bomb.mp3",   $resources_path + "block-green-hd.png"],
      [$resources_path + "coin07.mp3", $resources_path + "block-red-hd.png"],
      [$resources_path + "jump01.mp3", $resources_path + "block-yellow-hd.png"],
      [$resources_path + "laser3.mp3", "Icon-57.png"]
    ]
    @my_index = rand(@sound_and_icons.size) 
  end

  def _create_scene
    @win_size = CCDirector.sharedDirector.getWinSize

    @layer = Layer.new

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
    @layer.addChild(_create_reboot_menu)

    @scene = Scene.new
    @scene.addChild(@layer)

    ws_url = "ws://infinite-shelf-9645.herokuapp.com"
    # ws_url = "ws://echo.websocket.org"
    @ws = WebSocket.create(ws_url) do |event,data|
      if event=="message"
        begin
          obj = JSON.parse(data)
          if obj['tap']
            sound, icon = @sound_and_icons[obj['tap']['index']]
            sprite = Sprite.new(icon)
            sprite.setPosition(obj['tap']['x'], obj['tap']['y'])
            @layer.addChild(sprite)
            CocosDenshion::SimpleAudioEngine.sharedEngine.playEffect(sound)
          end
        rescue => e
          log "event=message e=#{e.inspect}"
        end
      end
      if event=="close"
        @ws = nil
      end
      log "ws: #{event} [#{data}]"
    end

    nil
  end

  def _create_reboot_menu
    menu = Menu.new
    menu.setPosition(0,0)
    item = MenuItemFont.new("reboot!")
    item.setAnchorPoint(ccp(0,0))
    item.setPosition(ccp(0,@win_size.height-30))
    item.registerScriptTapHandler do
      @ws.close
      Cocos2dx.reboot!
      log "*** reboot! ***"
    end
    menu.addChild(item)
    menu
  end

  def onTouchBegan(touch)
    point = @layer.convertTouchToNodeSpace(touch)
    log("onTouchBegan: #{point.x},#{point.y}")

    name = ["Icon-57.png","Icon-72.png","Icon-114.png","Icon-144.png"].sample
    @ws.send(JSON::stringify({handle: @handle, text:"TAP(#{point.x},#{point.y})", tap:{x:point.x, y:point.y, index:@my_index}})) if @ws

    return true
  end

  def onTouchMoved(touch)
    point = @layer.convertTouchToNodeSpace(touch)
    log("onTouchMoved: #{point.x},#{point.y}")
  end

  def onTouchEnded(touch)
    point = @layer.convertTouchToNodeSpace(touch)
    log("onTouchEnded: #{point.x},#{point.y}")

    @touch_count += 1
    log "@touch_count = #{@touch_count}"
  end
end

begin
  d = CCDirector.sharedDirector
  view = CCEGLView.sharedOpenGLView
  frame_size = view.getFrameSize
  view.setDesignResolutionSize(frame_size.width, frame_size.height, KResolutionExactFit)
  d.setDisplayStats(true)
  app = WsApp.new
  d.pushScene(app.scene.cc_object)
rescue => e
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end
