include Cocos2dx
fu = CCFileUtils.sharedFileUtils
fu.addSearchPath(fu.fullPathFromRelativeFile("", __FILE__))
#puts "SearchPaths:#{fu.getSearchPaths}"
Cocos2dxMrubyPlayer.load("../../lib/cocos2dx_support.rb")
Cocos2dx::Logger.add(Cocos2dx::WebSocketLogger.new("ws://192.168.0.6:9292"))

Cocos2dxMrubyPlayer.load("box.rb")

$box2d_to_pixel = 80.0
$world = Box2D::B2World.new(Box2D::B2Vec2.new(0,-9.8))

class Box2dApp1 < Box2dApp_Base
  def _create_boxes
    @layer.setPosition(1.9833,168.662)
    @layer.setScale(0.1045)

    # box2d
    width  = @win_size.width  / $box2d_to_pixel
    height = @win_size.height / $box2d_to_pixel

    ground0 = Box.new(:static,
      x = width/2,
      y = 0.10,
      w = width * 0.8,
      h = 100.0 * (0.50) / $box2d_to_pixel,
      a = 0,
      d = 0,
      [1.0,1.0,1.0]
    )
    @layer.addChild(ground0)

    ground1 = Box.new(:static,
      x = width*-1.3,
      y = -50.0,
      w = width * 0.8,
      h = 100.0 * (0.30) / $box2d_to_pixel,
      a = 0,
      d = 0,
      [1.0,1.0,1.0]
    )
    @layer.addChild(ground1)

    ground2 = Box.new(:static,
      x = width*1.3,
      y = -30.0,
      w = width * 0.8,
      h = 100.0 * (0.30) / $box2d_to_pixel,
      a = 0,
      d = 0,
      [1.0,1.0,1.0]
    )
    @layer.addChild(ground2)

    @boxes = []
    100.times do
      box = create_random_box
      @layer.addChild(box)
      @boxes << box
    end
  end

  def after_update(dt)
    @boxes.each do |box|
      box.update
      if box.body.getPosition.y < -100
        $world.destroyBody(box.body)
        box.removeFromParentAndCleanup(true)
        @boxes.delete(box)

        box = create_random_box
        @layer.addChild(box)
        @boxes << box
      end
    end
  end

  def create_random_box
    width  = @win_size.width  / $box2d_to_pixel
    height = @win_size.height / $box2d_to_pixel
    Box.new(:dynamic,
      x = rand*width,
      y = rand*height*3 + 5,
      w = 100.0 * (0.1 + rand) / $box2d_to_pixel,
      h = 100.0 * (0.1 + rand) / $box2d_to_pixel,
      a = 360 * rand,
      d = 0.1 + rand,
      [0.3+rand*0.7,0.3+rand*0.7,0.3+rand*0.7]
    )
  end
end

d = CCDirector.sharedDirector
view = CCEGLView.sharedOpenGLView
frame_size = view.getFrameSize
view.setDesignResolutionSize(frame_size.width, frame_size.height, KResolutionExactFit)
d.setDisplayStats(true)
app = Box2dApp1.new
d.pushScene(app.scene.cc_object)
