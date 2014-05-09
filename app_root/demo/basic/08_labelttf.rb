include Cocos2dx
fu = CCFileUtils.sharedFileUtils
fu.addSearchPath(fu.fullPathFromRelativeFile("", __FILE__))
#puts "SearchPaths:#{fu.getSearchPaths}"
Cocos2dxMrubyPlayer.load("../../lib/cocos2dx_support.rb")
#Cocos2dx::Logger.add(Cocos2dx::WebSocketLogger.new("ws://192.168.0.6:9292"))

class LabelTTFApp
  attr_reader :scene
  def initialize
    @win_size = CCDirector.sharedDirector.getWinSize
    @scene = Scene.new
    @layer = Layer.new
    @layer.registerScriptTouchHandler do |eventType, touch|
      reboot!
    end
    @layer.setTouchMode(KCCTouchesOneByOne)
    @layer.setTouchEnabled(true)

    @scene.addChild(@layer)

    add_sample(200, 500, "Left,Top\nX",      "", 30, KCCTextAlignmentLeft,   KCCVerticalTextAlignmentTop)
    add_sample(200, 350, "Left,Center\nX",   "", 30, KCCTextAlignmentLeft,   KCCVerticalTextAlignmentCenter)
    add_sample(200, 200, "Left,Bottom\nX",   "", 30, KCCTextAlignmentLeft,   KCCVerticalTextAlignmentBottom)
    add_sample(450, 500, "Center,Top\nX",    "", 30, KCCTextAlignmentCenter, KCCVerticalTextAlignmentTop)
    add_sample(450, 350, "Center,Center\nX", "", 30, KCCTextAlignmentCenter, KCCVerticalTextAlignmentCenter)
    add_sample(450, 200, "Center,Bottom\nX", "", 30, KCCTextAlignmentCenter, KCCVerticalTextAlignmentBottom)
    add_sample(700, 500, "Right,Top\nX",     "", 30, KCCTextAlignmentRight,  KCCVerticalTextAlignmentTop)
    add_sample(700, 350, "Right,Center\nX",  "", 30, KCCTextAlignmentRight,  KCCVerticalTextAlignmentCenter)
    add_sample(700, 200, "Right,Bottom\nX",  "", 30, KCCTextAlignmentRight,  KCCVerticalTextAlignmentBottom)
  end

  def add_sample(x, y, text, font, size, ah, av)
    w = 200
    h = 140

    rect = DrawNode.new
    points = [
      ccp(x-w/2, y-h/2),
      ccp(x-w/2, y+h/2),
      ccp(x+w/2, y+h/2),
      ccp(x+w/2, y-h/2)
    ]
    rect.drawPolygon(points,
                     ccc4f(0.3, 0.3, 0.3, 1.0),
                     1,
                     ccc4f(0.8, 0.8, 0.8, 1.0)
                     )
    rect.setZOrder(-100)
    @scene.addChild(rect)

    line1 = DrawNode.new
    line1.drawSegment(ccp(x-30, y), ccp(x+30, y), 1, ccc4f(1.0, 1.0, 1.0, 1.0))
    @scene.addChild(line1)

    line2 = DrawNode.new
    line2.drawSegment(ccp(x, y-30), ccp(x, y+30), 1, ccc4f(1.0, 1.0, 1.0, 1.0))
    @scene.addChild(line2)

    label = LabelTTF.new(text, font, size, cCSizeMake(w,h), ah, av)
    #label.setAnchorPoint(ccp(0,0))
    label.setPosition(x,y)

    @layer.addChild(label)
  end
end

d = CCDirector.sharedDirector
view = CCEGLView.sharedOpenGLView
frame_size = view.getFrameSize
view.setDesignResolutionSize(frame_size.width, frame_size.height, KResolutionExactFit)
d.setDisplayStats(true)
app = LabelTTFApp.new
d.pushScene(app.scene.cc_object)
