include Cocos2dx
fu = CCFileUtils.sharedFileUtils
fu.addSearchPath(fu.fullPathFromRelativeFile("", __FILE__))
#puts "SearchPaths:#{fu.getSearchPaths}"
Cocos2dxMrubyPlayer.load("../../lib/cocos2dx_support.rb")
Cocos2dx::Logger.add(Cocos2dx::WebSocketLogger.new("ws://192.168.0.6:9292"))

Cocos2dxMrubyPlayer.load("box.rb")

$box2d_to_pixel = 80.0
$world = Box2D::B2World.new(Box2D::B2Vec2.new(0.0,0.0))

class Box2dApp2 < Box2dApp_Base
  def _create_boxes
    log @layer.getPosition
    @layer.setPosition(0.0,0.0)
    @layer.setScale(1.0)

    # box2d
    width  = @win_size.width  / $box2d_to_pixel
    height = @win_size.height / $box2d_to_pixel

  if nil
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
  end

    @boxes = []
    200.times do |n|
      type = n % 4
      box = create_box(type)
      @layer.addChild(box)
      @boxes << box
      n += 1
    end
  end

  def after_update(dt)
    @boxes.each do |box|
      m = box.body.getMass
      box.body.applyForceToCenter(Box2D::B2Vec2.new(box.data[:gx]*m ,box.data[:gy]*m))
      box.update
      pos = box.body.getPosition
      if pos.y < -200 || 200 < pos.y || pos.x < -200 || 200 < pos.x
        $world.destroyBody(box.body)
        box.removeFromParentAndCleanup(true)
        @boxes.delete(box)
        box = create_box(box.data[:type])
        @layer.addChild(box)
        @boxes << box
      end
    end
  end

  def create_box(type)
    color, x, y, gx, gy, d = case type
      when 0
        [[1.0,0.0,0.0],    0, 6000,  0.0,-9.8, 9.0]
      when 1
        [[0.0,1.0,0.0], 6000,    0, -9.8, 0.0, 1.0]
      when 2
        [[0.0,0.5,1.0],    0,-6000,  0.0, 9.8, 3.0]
      when 3
        [[1.0,1.0,0.0],-6000,    0,  9.8, 0.0, 0.1]
      end

    box = Box.new(:dynamic,
      _x = (x + (rand-0.5)*1000) / $box2d_to_pixel,
      _y = (y + (rand-0.5)*1000) / $box2d_to_pixel,
      _w = 300.0 * (0.1 + rand)  / $box2d_to_pixel,
      _h = 300.0 * (0.1 + rand)  / $box2d_to_pixel,
      _a = 360 * rand,
      _d = d * 0.5 + rand,
      _c = color
    )
    box.data = {
      :type => type,
      :gx   => gx,
      :gy   => gy
    }
    box
  end
end

d = CCDirector.sharedDirector
view = CCEGLView.sharedOpenGLView
frame_size = view.getFrameSize
view.setDesignResolutionSize(frame_size.width, frame_size.height, KResolutionExactFit)
d.setDisplayStats(true)
app = Box2dApp2.new
d.pushScene(app.scene.cc_object)
