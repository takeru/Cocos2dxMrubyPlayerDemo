include Cocos2dx
fu = CCFileUtils.sharedFileUtils
fu.addSearchPath(fu.fullPathFromRelativeFile("..", __FILE__))
fu.addSearchPath(fu.fullPathFromRelativeFile(""))
#fu.getSearchPaths.each_with_index do |path,i|
#  puts "SearchPaths[#{i}]:#{path}"
#end
Cocos2dxMrubyPlayer.load("lib/cocos2dx_support.rb")
#Cocos2dx::Logger.add(Cocos2dx::WebSocketLogger.new("ws://192.168.0.6:9292"))

class MenuApp
  attr_reader :scene
  def initialize
    _create_scene
  end

  def _create_scene
    app_or_dbx = "?"
    if __FILE__.include?("Documents/dropbox_root")
      app_or_dbx = "Dbx"
    elsif __FILE__.include?(".app/app_root")
      app_or_dbx = "App"
    end

    @win_size = CCDirector.sharedDirector.getWinSize
    @layer = Layer.new

    menu = Menu.new
    menu.setPosition(0,0)
    menus = {
      "Hello"      =>{:load=>"demo/basic/01_hello.rb"      },
      "Sprite"     =>{:load=>"demo/basic/02_sprite.rb"     },
      "Touch"      =>{:load=>"demo/basic/03_touch.rb"      },
      "MultiTouch" =>{:load=>"demo/basic/04_multi_touch.rb"},
      "DrawNode"   =>{:load=>"demo/basic/05_drawnode.rb"   },
      "Update"     =>{:load=>"demo/basic/06_update.rb"     },
      "Ext"        =>{:load=>"demo/basic/07_ext.rb"        },
      "LabelTTF"   =>{:load=>"demo/basic/08_labelttf.rb"   },
      "NyanGame"   =>{:load=>"demo/nyangame/nyangame.rb"   },
      "Kani"       =>{:load=>"demo/kani/app.rb"            },
      "WebSocket"  =>{:load=>"demo/websocket/app.rb"       },
      "Box2d"      =>{:load=>"demo/box2d/app.rb"           },
      "*GitHub"    =>{:url =>"https://github.com/takeru/Cocos2dxMrubyPlayerDemo"},
      "*TestFlight"=>{:url =>"https://testflightapp.com/m/apps"},
      "*Setup"     =>{:load=>"setup/app.rb"                },
      "*(#{app_or_dbx})" =>{},
    }

    rows = 3
    cols = 8
    index = 0
    menus.each do |text,action|
      item = MenuItemFont.new(text)
      item.setFontSizeObj(50)
      col = (index/rows).floor
      row =  index%rows
      item.setPosition(
        (1+col)*(@win_size.width/cols),
        @win_size.height - (@win_size.height/rows) * (0.2+row + 0.5*(col%2))
      )
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
  end
end

begin
  d = Cocos2dx::CCDirector.sharedDirector
  view = Cocos2dx::CCEGLView.sharedOpenGLView
  frame_size = view.getFrameSize
  view.setDesignResolutionSize(frame_size.width, frame_size.height, Cocos2dx::KResolutionExactFit)
  d.setDisplayStats(false)
  app = MenuApp.new
  d.pushScene(app.scene.cc_object)
rescue => e
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end
