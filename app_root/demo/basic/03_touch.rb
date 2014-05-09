include Cocos2dx
fu = CCFileUtils.sharedFileUtils
fu.addSearchPath("")
fu.addSearchPath(fu.fullPathFromRelativeFile("", __FILE__))
#puts "SearchPaths:#{fu.getSearchPaths}"
Cocos2dxMrubyPlayer.load("../../lib/cocos2dx_support.rb")
#Cocos2dx::Logger.add(Cocos2dx::WebSocketLogger.new("ws://192.168.0.6:9292"))

class TouchApp
  attr_reader :scene
  def initialize
    @touch_count = 0

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
        raise "unknown eventType=#{eventType} touch=#{touch}"
      end
    end
    @layer.setTouchMode(KCCTouchesOneByOne)
    @layer.setTouchEnabled(true)

    @scene = Scene.new
    @scene.addChild(@layer)

    @log_layer = LogLayer.new
    @scene.addChild(@log_layer)
    Logger.add(@log_layer)

    nil
  end

  def onTouchBegan(touch)
    point = @layer.convertTouchToNodeSpace(touch)
    log("onTouchBegan: #{point.x},#{point.y}")

    name = ["Icon-57.png","Icon-72.png","Icon-114.png","Icon-144.png"].sample
    @sprite = Sprite.new(name)
    @sprite.setPosition(point.x, point.y)
    @layer.addChild(@sprite)

    return true
  end

  def onTouchMoved(touch)
    point = @layer.convertTouchToNodeSpace(touch)
    log("onTouchMoved: #{point.x},#{point.y}")

    @sprite.setPosition(point.x, point.y)
  end

  def onTouchEnded(touch)
    point = @layer.convertTouchToNodeSpace(touch)
    log("onTouchEnded: #{point.x},#{point.y}")

    @touch_count += 1
    log "@touch_count = #{@touch_count}"
    if 10 < @touch_count
      reboot!
    end
  end

  def onTouchCanceled(touch)
    onTouchEnded(touch)
  end
end

d = CCDirector.sharedDirector
view = CCEGLView.sharedOpenGLView
frame_size = view.getFrameSize
view.setDesignResolutionSize(frame_size.width, frame_size.height, KResolutionExactFit)
d.setDisplayStats(true)
app = TouchApp.new
d.pushScene(app.scene.cc_object)
