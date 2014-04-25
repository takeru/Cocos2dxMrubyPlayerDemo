class SpriteApp
  attr_reader :scene
  def initialize
    @win_size = Cocos2d::CCDirector.sharedDirector.getWinSize

    layer = Layer.new

    ["Icon-57.png","Icon-72.png","Icon-114.png","Icon-144.png"].each do |name|
      sprite = Sprite.new(name)
      sprite.setPosition(@win_size.width*rand, @win_size.height*rand)
      layer.addChild(sprite)
    end

    menu = Menu.new
    menu.setPosition(0,0)
    item = MenuItemFont.new("reboot!")
    item.setPosition(@win_size.width*0.5, @win_size.height*0.25)
    item.registerScriptTapHandler do
      puts "*** reboot! ***"
      Cocos2dx.reboot!
    end
    menu.addChild(item)

    layer.addChild(menu)

    @scene = Scene.new
    @scene.addChild(layer)
  end
end

begin
  d = Cocos2d::CCDirector.sharedDirector
  view = Cocos2d::CCEGLView.sharedOpenGLView
  frame_size = view.getFrameSize
  view.setDesignResolutionSize(frame_size.width, frame_size.height, Cocos2d::KResolutionExactFit)
  d.setDisplayStats(true)
  app = SpriteApp.new
  d.pushScene(app.scene.cc_object)
rescue => e
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end
