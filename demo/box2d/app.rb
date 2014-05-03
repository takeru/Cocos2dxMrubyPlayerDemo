
$box2d_to_pixel = 80.0
$view_point = CCPoint.new

class Box < DrawNode
  def initialize
    @cc_class_name = 'CCDrawNode'
    super
  end
  attr_accessor :body
  def update
    pos = @body.getPosition
    setPosition(
      pos.x * $box2d_to_pixel + $view_point.x,
      pos.y * $box2d_to_pixel + $view_point.y
    )
    setRotation(-@body.getAngle * 180 / 3.141592)
  end
end

class Box2dApp
  attr_reader :scene
  def initialize
    _create_scene
  end

  def _create_scene
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

    @layer.addChild(_create_reboot_menu)

    # box2d
    width  = @win_size.width  / $box2d_to_pixel
    height = @win_size.height / $box2d_to_pixel
    @world = Box2D::B2World.new(Box2D::B2Vec2.new(0,-9.8))
    @ground = _create_box(:static,
      x = width/2,
      y = 0.10,
      w = width * 0.8,
      h = 100.0 * (0.10) / $box2d_to_pixel,
      a = 0,
      d = 0,
      [1.0,1.0,1.0]
    )
    @layer.addChild(@ground)
    @boxes = []
    100.times do
      box = _create_box(:dynamic,
        x = rand*width,
        y = rand*height*3 + 5,
        w = 100.0 * (0.1 + rand) / $box2d_to_pixel,
        h = 100.0 * (0.1 + rand) / $box2d_to_pixel,
        a = 360 * rand,
        d = 0.1 + rand,
        [0.3+rand*0.7,0.3+rand*0.7,0.3+rand*0.7]
      )
      @layer.addChild(box)
      @boxes << box
    end

    @scene = Scene.new
    @scene.addChild(@layer)

    @layer.scheduleUpdateWithPriorityLua(1) do |dt,node|
      @world.step(dt, 8, 3)
      @boxes.each do |box|
        box.update
      end
      @ground.update
    end

    nil
  end

  def _create_reboot_menu
    menu = Menu.new
    menu.setPosition(0,0)
    item = MenuItemFont.new("reboot!")
    item.setAnchorPoint(ccp(0,0))
    item.setPosition(ccp(0,@win_size.height-30))
    item.registerScriptTapHandler do
      reboot!
      log "*** reboot! ***"
    end
    menu.addChild(item)
    menu
  end

  B2BodyType_Map = {
    :dynamic   => Box2D::B2_dynamicBody,
    :static    => Box2D::B2_staticBody,
    :kinematic => Box2D::B2_kinematicBody
  }

  def _create_box(type, x, y, width, height, angle, density, color)
    bd = Box2D::B2BodyDef.new
    bd.type = B2BodyType_Map[type]
    bd.position = Box2D::B2Vec2.new(x, y)
    bd.angle = angle
    body = @world.createBody(bd)

    shape = Box2D::B2PolygonShape.new
    shape.setAsBox(width/2,height/2)
    fixture = body.createFixture(shape, density)

    node = Box.new
    points = [
      ccp(-width/2*$box2d_to_pixel, -height/2*$box2d_to_pixel),
      ccp( width/2*$box2d_to_pixel, -height/2*$box2d_to_pixel),
      ccp( width/2*$box2d_to_pixel,  height/2*$box2d_to_pixel),
      ccp(-width/2*$box2d_to_pixel,  height/2*$box2d_to_pixel)
    ]
    node.drawPolygon(points,
      ccc4f(color[0], color[1], color[2], 1),
      0,
      ccc4f(0, 0, 0, 0)
    )
    node.body = body
    node.update
    return node
  end

  def onTouchBegan(touch)
    point = @layer.convertTouchToNodeSpace(touch)
    #log("onTouchBegan: #{point.x},#{point.y}")

    @touching_point = point
    return true
  end

  def onTouchMoved(touch)
    point = @layer.convertTouchToNodeSpace(touch)
    #log("onTouchMoved: #{point.x},#{point.y}")

    $view_point.x += point.x - @touching_point.x
    $view_point.y += point.y - @touching_point.y
    @touching_point = point
  end

  def onTouchEnded(touch)
    #point = @layer.convertTouchToNodeSpace(touch)
    #log("onTouchEnded: #{point.x},#{point.y}")

    @touching_point = nil
  end
end

begin
  d = CCDirector.sharedDirector
  view = CCEGLView.sharedOpenGLView
  frame_size = view.getFrameSize
  view.setDesignResolutionSize(frame_size.width, frame_size.height, KResolutionExactFit)
  d.setDisplayStats(true)
  app = Box2dApp.new
  d.pushScene(app.scene.cc_object)
rescue => e
  log "ERROR #{e.inspect} #{e.backtrace.first}"
end
