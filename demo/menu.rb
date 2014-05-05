Cocos2dxMrubyPlayer.load("$DB/demo/cocos2dx_support.rb")
Cocos2dx::Logger.add(Cocos2dx::WebSocketLogger.new("ws://192.168.0.6:9292"))
log "==== cocos2dx.rb loaded. ===="
include Cocos2dx
CCFileUtils.sharedFileUtils.removeAllPaths
CCFileUtils.sharedFileUtils.addSearchPath("")
CCFileUtils.sharedFileUtils.getSearchPaths.each_with_index do |path,i|
  log "SearchPaths[#{i}]:#{path}"
end

class MenuApp
  attr_reader :scene
  def initialize
    _create_scene
  end

  def _create_scene
    @win_size = CCDirector.sharedDirector.getWinSize
    @layer = Layer.new

    menu = Menu.new
    menu.setPosition(0,0)
    menus = {
      "Hello"      =>{:load=>"$DB/demo/basic/01_hello.rb"      },
      "Sprite"     =>{:load=>"$DB/demo/basic/02_sprite.rb"     },
      "Touch"      =>{:load=>"$DB/demo/basic/03_touch.rb"      },
      "MultiTouch" =>{:load=>"$DB/demo/basic/04_multi_touch.rb"},
      "DrawNode"   =>{:load=>"$DB/demo/basic/05_drawnode.rb"   },
      "Update"     =>{:load=>"$DB/demo/basic/06_update.rb"     },
      "Ext"        =>{:load=>"$DB/demo/basic/07_ext.rb"        },
      "LabelTTF"   =>{:load=>"$DB/demo/basic/08_labelttf.rb"   },
      "NyanGame"   =>{:load=>"$DB/demo/nyangame/nyangame.rb"   },
      "Kani"       =>{:load=>"$DB/demo/kani/app.rb"            },
      "WebSocket"  =>{:load=>"$DB/demo/websocket/app.rb"       },
      "Box2d"      =>{:load=>"$DB/demo/box2d/app.rb"           },
      "GitHub"     =>{:url =>"https://github.com/takeru/Cocos2dxMrubyPlayerDemo"},
      "TestFlight" =>{:url =>"https://testflightapp.com/m/apps"},
    }

    rows = 3
    cols = 8
    index = 0
    menus.each do |text,action|
      item = MenuItemFont.new(text)
      item.setFontSizeObj(50)
      item.setAnchorPoint(ccp(0,0))
      col = (index/rows).floor
      row =  index%rows
      item.setPosition(ccp(
        30+col*(@win_size.width/cols),
        @win_size.height - (@win_size.height/rows) * (0.3+row + 0.5*(col%2))
      ))
      item.registerScriptTapHandler do
        log "Menu: #{text} selected."
        begin
          if action[:load]
            Cocos2dxMrubyPlayer.load(action[:load])
          elsif action[:url]
            Cocos2dxMrubyPlayer.open_url(action[:url])
          end
        rescue => e
          log "failed to load '#{text}'. e=#{e.inspect}"
        end
      end
      menu.addChild(item)
      index += 1
    end
    @layer.addChild(menu)

    @scene = Scene.new
    @scene.addChild(@layer)

    nil
  end
end

begin
  d = Cocos2dx::CCDirector.sharedDirector
  view = Cocos2dx::CCEGLView.sharedOpenGLView
  frame_size = view.getFrameSize
  view.setDesignResolutionSize(frame_size.width, frame_size.height, Cocos2dx::KResolutionExactFit)
  #CCEGLView.sharedOpenGLView.setDesignResolutionSize(480*2,320*2,KResolutionExactFit)
  #d.setContentScaleFactor(1.0)
  d.setDisplayStats(false)

  app = MenuApp.new
  d.pushScene(app.scene.cc_object)
rescue => e
  puts "a"
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end
