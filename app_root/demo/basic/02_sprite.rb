include Cocos2dx
fu = CCFileUtils.sharedFileUtils
fu.addSearchPath("")
fu.addSearchPath(fu.fullPathFromRelativeFile("", __FILE__))
#puts "SearchPaths:#{fu.getSearchPaths}"
Cocos2dxMrubyPlayer.load("../../lib/cocos2dx_support.rb")
#Cocos2dx::Logger.add(Cocos2dx::WebSocketLogger.new("ws://192.168.0.6:9292"))

class SpriteApp
  attr_reader :scene
  def initialize
    @win_size = CCDirector.sharedDirector.getWinSize

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
      reboot!
    end
    menu.addChild(item)

    layer.addChild(menu)

    @scene = Scene.new
    @scene.addChild(layer)
  end
end

d = CCDirector.sharedDirector
view = CCEGLView.sharedOpenGLView
frame_size = view.getFrameSize
view.setDesignResolutionSize(frame_size.width, frame_size.height, KResolutionExactFit)
d.setDisplayStats(true)
app = SpriteApp.new
d.pushScene(app.scene.cc_object)
