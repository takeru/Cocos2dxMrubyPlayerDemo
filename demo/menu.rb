Cocos2dxMrubyPlayer.load("demo/cocos2dx.rb")
Cocos2dx::WebSocketLogger.url = "ws://192.168.0.6:9292"
log "==== cocos2dx.rb loaded. ===="
include Cocos2dx

class MenuApp
  attr_reader :scene
  def initialize
    _create_scene
  end

  def _create_scene
    @win_size = Cocos2d::CCDirector.sharedDirector.getWinSize

    @layer = Layer.new

    menu = Menu.new
    menu.setPosition(0,0)
    filenames = [
      "basic/01_hello.rb",
      "basic/02_sprite.rb",
      "basic/03_touch.rb",
      "basic/04_multi_touch.rb",
      "basic/05_drawnode.rb",
      "basic/06_update.rb",
     #"basic/07_sound.rb",
      "nyangame/nyangame.rb",
      "kani/app.rb",
      "websocket/app.rb",
      "box2d/app.rb"
    ]

    rows = 6
    cols = 3
    filenames.each_with_index do |filename, index|
      item = MenuItemFont.new(filename)
      item.setAnchorPoint(Cocos2d::ccp(0,0))
      item.setPosition(Cocos2d::ccp(
        10+(index/rows).floor*(@win_size.width/cols),
        @win_size.height - (@win_size.height/rows) * (0.5+index%rows)
      ))
      item.registerScriptTapHandler do
        log "Menu: #{filename} selected."
        Cocos2dxMrubyPlayer.load("demo/"+filename)
      end
      menu.addChild(item)
    end
    @layer.addChild(menu)

    @scene = Scene.new
    @scene.addChild(@layer)

    nil
  end
end

begin
  d = Cocos2d::CCDirector.sharedDirector
  view = Cocos2d::CCEGLView.sharedOpenGLView
  frame_size = view.getFrameSize
  view.setDesignResolutionSize(frame_size.width, frame_size.height, Cocos2d::KResolutionExactFit)
  #Cocos2d::CCEGLView.sharedOpenGLView.setDesignResolutionSize(480*2,320*2,Cocos2d::KResolutionExactFit)
  #d.setContentScaleFactor(1.0)
  d.setDisplayStats(false)

  app = MenuApp.new
  d.pushScene(app.scene.cc_object)
rescue => e
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end
