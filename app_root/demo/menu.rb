include Cocos2dx
fu = CCFileUtils.sharedFileUtils
fu.addSearchPath(fu.fullPathFromRelativeFile("", __FILE__))
#puts "SearchPaths:#{fu.getSearchPaths}"
Cocos2dxMrubyPlayer.load("../lib/cocos2dx_support.rb")
#Cocos2dx::Logger.add(Cocos2dx::WebSocketLogger.new("ws://192.168.0.6:9292"))

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
      "*Setup"     =>{:reboot=>"setup/app.rb"                },
      "*GitHub"    =>{:url   =>"https://github.com/takeru/Cocos2dxMrubyPlayerDemo"},
      "*TestFlight"=>{:url   =>"https://testflightapp.com/m/apps"},
      "Hello"      =>{:reboot=>"demo/basic/01_hello.rb"      },
      "Sprite"     =>{:reboot=>"demo/basic/02_sprite.rb"     },
      "Touch"      =>{:reboot=>"demo/basic/03_touch.rb"      },
      "MultiTouch" =>{:reboot=>"demo/basic/04_multi_touch.rb"},
      "DrawNode"   =>{:reboot=>"demo/basic/05_drawnode.rb"   },
      "Update"     =>{:reboot=>"demo/basic/06_update.rb"     },
      "Ext"        =>{:reboot=>"demo/basic/07_ext.rb"        },
      "LabelTTF"   =>{:reboot=>"demo/basic/08_labelttf.rb"   },
      "NyanGame"   =>{:reboot=>"demo/nyangame/nyangame.rb"   },
      "Kani"       =>{:reboot=>"demo/kani/app.rb"            },
      "WebSocket"  =>{:reboot=>"demo/websocket/app.rb"       },
      "Box2d"      =>{:reboot=>"demo/box2d/app.rb"           },
      "Flappy"     =>{:reboot=>"demo/flappy/flappy.rb"       },
      "Mikiri"     =>{:reboot=>"demo/mikiri/mikiri.rb"       },
    }

    items_in_row = 3
    rows = 8
    index = 0
    menus.each do |text,action|
      item = MenuItemFont.new(text)
      item.setFontSizeObj(50)
      row = (index/items_in_row).floor
      col = index%items_in_row
      x = (0.5+col)*(@win_size.width/items_in_row)
      y = @win_size.height - (@win_size.height/rows) * (0.5+row)
      item.setPosition(x, y)
      item.registerScriptTapHandler do
        log "Menu: #{text} selected."
        begin
          #if action[:load]
          #  Cocos2dxMrubyPlayer.load(action[:load])
          #els
          if action[:reboot]
            path = action[:reboot]
            case app_or_dbx
            when :dropbox
              path = "$DBX/app_root/#{path}"
            when :app
              path = "$APP/#{path}"
            else
              raise
            end
            Cocos2dxMrubyPlayer.reboot!(path)
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

    label = LabelTTF.new("(this menu is loaded from #{app_or_dbx})", "Marker Felt", 20)
    label.setPosition(@win_size.width/2,50)
    @layer.addChild(label)

    @scene = Scene.new
    @scene.addChild(@layer)
  end

  def app_or_dbx
    if __FILE__.include?("Documents/dropbox_root")
      :dropbox
    elsif __FILE__.include?(".app/app_root")
      :app
    else
      :unknown
    end
  end
end


d = Cocos2dx::CCDirector.sharedDirector
view = Cocos2dx::CCEGLView.sharedOpenGLView
frame_size = view.getFrameSize
view.setDesignResolutionSize(frame_size.width, frame_size.height, Cocos2dx::KResolutionExactFit)
d.setDisplayStats(false)
app = MenuApp.new
d.pushScene(app.scene.cc_object)
