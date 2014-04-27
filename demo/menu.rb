Cocos2dxMrubyPlayer.load("demo/cocos2dx_support.rb")
include Cocos2dx
WebSocketLogger.url = "ws://192.168.0.6:9292"
log "==== cocos2dx.rb loaded. ===="

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
    filenames = [
      "basic/01_hello.rb",
      "basic/02_sprite.rb",
      "basic/03_touch.rb",
      "basic/04_multi_touch.rb",
      "basic/05_drawnode.rb",
      "basic/06_update.rb",
      "basic/07_ext.rb",
      "basic/08_labelttf.rb",
      "nyangame/nyangame.rb",
      "kani/app.rb",
      "websocket/app.rb",
      "box2d/app.rb"
    ]

    rows = 6
    cols = 3
    filenames.each_with_index do |filename, index|
      item = MenuItemFont.new(filename)
      item.setAnchorPoint(ccp(0,0))
      item.setPosition(ccp(
        10+(index/rows).floor*(@win_size.width/cols),
        @win_size.height - (@win_size.height/rows) * (0.5+index%rows)
      ))
      item.registerScriptTapHandler do
        log "Menu: #{filename} selected."
        begin
          Cocos2dxMrubyPlayer.load("demo/"+filename)
        rescue => e
          log "failed to load '#{filename}'. e=#{e.inspect}"
        end
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
