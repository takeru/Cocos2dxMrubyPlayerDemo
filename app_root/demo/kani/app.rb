include Cocos2dx
fu = CCFileUtils.sharedFileUtils
fu.addSearchPath(fu.fullPathFromRelativeFile("", __FILE__))
#puts "SearchPaths:#{fu.getSearchPaths}"
Cocos2dxMrubyPlayer.load("../../lib/cocos2dx_support.rb")
#Cocos2dx::Logger.add(Cocos2dx::WebSocketLogger.new("ws://192.168.0.6:9292"))
fu.addSearchPath(fu.fullPathFromRelativeFile("resources", fu.fullPathForFilename(__FILE__)))

RATE = 45

%w(bg stage kani player).each do |x|
  Cocos2dxMrubyPlayer.load("#{x}.rb")
end

class KaniApp
  attr_reader :scene

  def initialize
    @win_size = CCDirector.sharedDirector.getWinSize
    _create_scene
  end

  def _create_scene
    @stage = Stage.new

    @scene = Scene.new
    @scene.addChild(@stage)

    CocosDenshion::SimpleAudioEngine.sharedEngine.preloadEffect 'complete.wav'
    CocosDenshion::SimpleAudioEngine.sharedEngine.preloadEffect 'blip.wav'
    CocosDenshion::SimpleAudioEngine.sharedEngine.preloadEffect 'reset.wav'
  end
end

puts "DesignResolutionSize #{CCEGLView.sharedOpenGLView.getDesignResolutionSize}"
CCEGLView.sharedOpenGLView.setDesignResolutionSize(480,320,KResolutionExactFit)
d = CCDirector.sharedDirector
d.setContentScaleFactor(1.0)
d.setDisplayStats(true)
app = KaniApp.new
d.pushScene(app.scene.cc_object)
