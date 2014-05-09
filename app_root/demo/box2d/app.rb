include Cocos2dx
fu = CCFileUtils.sharedFileUtils
fu.addSearchPath(fu.fullPathFromRelativeFile("", __FILE__))
#puts "SearchPaths:#{fu.getSearchPaths}"
Cocos2dxMrubyPlayer.load("../../lib/cocos2dx_support.rb")
Cocos2dx::Logger.add(Cocos2dx::WebSocketLogger.new("ws://192.168.0.6:9292"))

$box2d_to_pixel = 80.0
$world = Box2D::B2World.new(Box2D::B2Vec2.new(0,-9.8))

class Box < DrawNode
  def initialize(type, x, y, width, height, angle, density, color)
    @cc_class_name = 'CCDrawNode'
    super()

    bd = Box2D::B2BodyDef.new
    bd.type = B2BodyType_Map[type]
    bd.position = Box2D::B2Vec2.new(x, y)
    bd.angle = angle
    @body = $world.createBody(bd)

    shape = Box2D::B2PolygonShape.new
    shape.setAsBox(width/2,height/2)
    fixture = @body.createFixture(shape, density)

    points = [
      ccp(-width/2*$box2d_to_pixel, -height/2*$box2d_to_pixel),
      ccp( width/2*$box2d_to_pixel, -height/2*$box2d_to_pixel),
      ccp( width/2*$box2d_to_pixel,  height/2*$box2d_to_pixel),
      ccp(-width/2*$box2d_to_pixel,  height/2*$box2d_to_pixel)
    ]
    drawPolygon(points,
      ccc4f(color[0], color[1], color[2], 1),
      0,
      ccc4f(0, 0, 0, 0)
    )
    update
  end

  B2BodyType_Map = {
    :dynamic   => Box2D::B2_dynamicBody,
    :static    => Box2D::B2_staticBody,
    :kinematic => Box2D::B2_kinematicBody
  }

  attr_reader :body
  def update
    pos = @body.getPosition
    setPosition(
      pos.x * $box2d_to_pixel,
      pos.y * $box2d_to_pixel
    )
    setRotation(-@body.getAngle * 180 / 3.141592)

    if pos.y < -100
      return false
    else
      return true
    end
  end
end

class Box2dApp
  attr_reader :scene
  def initialize
    @touches = {}
    _create_scene
  end

  def _create_scene
    @win_size = CCDirector.sharedDirector.getWinSize

    @layer = Layer.new
    @layer.setPosition(1.9833,168.662)
    @layer.setScale(0.1045)

    _setup_touch
    _create_boxes

    @scene = Scene.new
    @scene.addChild(@layer)

    @layer.scheduleUpdateWithPriorityLua(1) do |dt,node|
      update(dt)
    end

    @layer_fixed = Layer.new
    @layer_fixed.addChild(_create_reboot_menu)
    @scene.addChild(@layer_fixed)

    nil
  end

  def _create_boxes
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

  def update(dt)
    $world.step(dt, 8, 3)
    @boxes.each do |box|
      unless box.update
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

  def _setup_touch
    @layer.setTouchMode(KCCTouchesOneByOne)
    @layer.registerScriptTouchHandler(false) do |eventType, touch|
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
        raise "unknown eventType=#{eventType} touches=#{touches.inspect}"
      end
    end
    @layer.setTouchEnabled(true)
  end

  def onTouchBegan(touch)
    if @touches.size < 2
      @touches[touch.getID] = touch.getLocation
      return true
    end
    return false
  end

  def onTouchMoved(touch)
    if @touches.size == 1
      if @touches[touch.getID]
        p0 = touch.getPreviousLocation # @layer.convertToNodeSpace
        p1 = touch.getLocation
        pos = @layer.getPosition
        pos.x += p1.x - p0.x
        pos.y += p1.y - p0.y
        @layer.setPosition(pos)
        @touches[touch.getID] = touch.getLocation
      end
    elsif @touches.size == 2
      a0 = @touches[0]
      b0 = @touches[1]
      c0 = CCPoint.new((a0.x+b0.x)/2,(a0.y+b0.y)/2)
      l0 = Math.sqrt((a0.x-b0.x)**2 + (a0.y-b0.y)**2)

      @touches[touch.getID] = touch.getLocation

      a1 = @touches[0]
      b1 = @touches[1]
      c1 = CCPoint.new((a1.x+b1.x)/2,(a1.y+b1.y)/2)
      l1 = Math.sqrt((a1.x-b1.x)**2 + (a1.y-b1.y)**2)

      pos = @layer.getPosition
      pos.x += c1.x - c0.x
      pos.y += c1.y - c0.y
      pos.x *= l1/l0
      pos.y *= l1/l0
      @layer.setPosition(pos)

      scale = @layer.getScale * l1/l0
      @layer.setScale(scale)

      #log "pos=#{pos.x},#{pos.y} scale=#{scale}"
    else
      log "@touches.size = #{@touches.size}"
    end
  end

  def onTouchEnded(touch)
    @touches.delete(touch.getID)
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
app = Box2dApp.new
d.pushScene(app.scene.cc_object)
