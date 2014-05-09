include Cocos2dx
fu = CCFileUtils.sharedFileUtils
fu.addSearchPath(fu.fullPathFromRelativeFile("", __FILE__))
#puts "SearchPaths:#{fu.getSearchPaths}"
Cocos2dxMrubyPlayer.load("../../lib/cocos2dx_support.rb")
#Cocos2dx::Logger.add(Cocos2dx::WebSocketLogger.new("ws://192.168.0.6:9292"))
fu.addSearchPath(fu.fullPathFromRelativeFile("resources", fu.fullPathForFilename(__FILE__)))

class Block < Sprite
  attr_reader :color
  attr_accessor :next_x, :next_y
  def initialize(color)
    @cc_class_name = 'CCSprite'
    super(color.to_s + ".png")

    @color = color
    @next_x = -1
    @next_y = -1
  end
  def to_s
    super + " #{color} #{getTag} #{next_x} #{next_y}"
  end
end

class NyanGame
  ZORDER = {
    :bg         =>   0,
    :block      => 200,
    :label      => 300,
    :gameover   => 400
  }
  TAG = {
    :bg           =>    1,
    :label_red    =>  101,
    :label_blue   =>  102,
    :label_yellow =>  103,
    :label_green  =>  104,
    :label_gray   =>  105,
    :label_score  =>  106,
    :gameover     =>  201,
    :block_base   => 1000,
  }
  COLORS = [:red, :blue, :yellow, :green, :gray]
  BLOCK_MAX_X = 8
  BLOCK_MAX_Y = 8
  MP3_REMOVE_BLOCK = "removeBlock.mp3"
  REMOVEING_TIME = 0.1
  MOVING_TIME_1  = 0.2
  MOVING_TIME_2  = 0.2

  attr_reader :scene

  def initialize
    @win_size = CCDirector.sharedDirector.getWinSize
    @animating = false
    @score     = 0
    _create_scene
  end

  def _create_scene
    @layer = Layer.new

    @touchBeginPoint = nil
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
        raise "unknown eventType=#{eventType}"
      end
    end
    @layer.setTouchMode(KCCTouchesOneByOne)
    @layer.setTouchEnabled(true)

    @bg = Sprite.new("background.png")
    @bg.setPosition(@win_size.width/2, @win_size.height/2)
    @layer.addChild(@bg, ZORDER[:bg], TAG[:bg])

    @scene = Scene.new
    @scene.addChild(@layer)
    @block_size = Block.new(:red).getContentSize.height

    _create_blocks
    _create_labels
    _update_labels
    _create_menus

    CocosDenshion::SimpleAudioEngine.sharedEngine.preloadEffect(MP3_REMOVE_BLOCK)
  end

  def blockCCPoint(x, y)
    offsetX = @bg.getContentSize.width  * 0.168
    offsetY = @bg.getContentSize.height * 0.029
    return ccp(
      (x+0.5) * @block_size + offsetX,
      (y+0.5) * @block_size + offsetY
    )
  end

  def xy_to_block_tag(x, y)
    TAG[:block_base] + x * 100 + y
  end

  def block_tag_to_xy(blockTag)
    t = blockTag - TAG[:block_base]
    return [(t/100).floor, t%100]
  end

  def _create_blocks
    (0...BLOCK_MAX_X).each do |x|
      (0...BLOCK_MAX_Y).each do |y|
        color = COLORS[rand(COLORS.size)]
        block = Block.new(color)
        block.setPosition(blockCCPoint(x,y))
        @bg.addChild(block, ZORDER[:block], xy_to_block_tag(x,y))
      end
    end
  end

  def _create_labels
    bg_size = @bg.getContentSize
    height_rates = {
      :red    => 0.61,
      :blue   => 0.51,
      :yellow => 0.41,
      :green  => 0.31,
      :gray   => 0.21
    }
    COLORS.each do |color|
      label = LabelBMFont.new("", "#{color}Font.fnt")
      label.setPosition(ccp(bg_size.width * 0.78, bg_size.height * height_rates[color]))
      @bg.addChild(label, ZORDER[:label], TAG[:"label_#{color}"])
    end

    # score
    label = LabelBMFont.new("", "whiteFont.fnt")
    label.setPosition(ccp(bg_size.width * 0.78, bg_size.height * 0.75))
    @bg.addChild(label, ZORDER[:label], TAG[:label_score])

    # highscore
    label = LabelBMFont.new("", "whiteFont.fnt")
    label.setPosition(ccp(bg_size.width * 0.78, bg_size.height * 0.87))
    @bg.addChild(label, ZORDER[:label], TAG[:label_highscore])
  end

  def _update_labels
    block_counts = {
      :red    => 0,
      :blue   => 0,
      :yellow => 0,
      :green  => 0,
      :gray   => 0
    }
    (0...BLOCK_MAX_X).each do |_x|
      (0...BLOCK_MAX_Y).each do |_y|
        tag = xy_to_block_tag(_x,_y)
        block = @bg.getChildByTag(tag)
        if block
          block_counts[block.color] += 1
        end
      end
    end

    def _create_menus
      bg_size = @bg.getContentSize

      reset_button = MenuItemImage.new("reset1.png", "reset1.png")
      reset_button.setPosition(ccp(bg_size.width * 0.78, bg_size.height * 0.1))
      reset_button.registerScriptTapHandler do
        _reset
      end

      menu = Menu.createWithItem(reset_button)
      menu.setPosition(0,0)

      @bg.addChild(menu)
    end

    COLORS.each do |color|
      label = @bg.getChildByTag(TAG[:"label_#{color}"])
      label.setString(block_counts[color].to_s)
    end

    # score
    label = @bg.getChildByTag(TAG[:label_score])
    label.setString(@score.to_s)

    # highscore
    highscore = CCUserDefault.sharedUserDefault.getIntegerForKey("highscore", 0)
    label = @bg.getChildByTag(TAG[:label_highscore])
    label.setString(highscore.to_s)
  end

  def _reset
    if gameover?
      reboot!
      puts "**** reboot! ****"
      return
    end
    d = CCDirector.sharedDirector
    nyangame = NyanGame.new
    d.replaceScene(nyangame.scene.cc_object)
  end

  def onTouchBegan(touch)
    return !@animating
  end

  def onTouchMoved(touch)
  end

  def onTouchEnded(touch)
    point = @bg.convertTouchToNodeSpace(touch)
    puts("onTouchEnded: #{point.x},#{point.y}")

    block = find_touched_block(touch)
    puts("touch=#{block}")
    if block
      blocks = find_same_color_neighboring_blocks(block)
      if 0<blocks.size
        @score += (blocks.size-2) ** 2
        @animating = true
        delete_blocks(blocks)
        move_blocks1(blocks)
      end
    end
  end

  def onTouchCanceled(touch)
    onTouchEnded(touch)
  end

  def find_touched_block(touch)
    point = @bg.convertTouchToNodeSpace(touch)

    (0...BLOCK_MAX_X).each do |_x|
      (0...BLOCK_MAX_Y).each do |_y|
        tag = xy_to_block_tag(_x,_y)
        block = @bg.getChildByTag(tag)
        if block && block.boundingBox.containsPoint(ccp(point.x,point.y))
          return block
        end
      end
    end

    return nil
  end

  def find_same_color_neighboring_blocks(block, blocks=[])
    [-1, +1, -100, +100].each do |n|
      b = @bg.getChildByTag(block.getTag()+n)
      if b && b.color==block.color && !blocks.include?(b)
        blocks << b
        find_same_color_neighboring_blocks(b, blocks)
      end
    end
    return blocks
  end

  def delete_blocks(blocks)
    blocks.each_with_index do |b, index|
      scale_action = CCScaleTo.create(REMOVEING_TIME, 0)
      remove_action = CCCallFunc.create do
        b.removeFromParentAndCleanup(true)
      end
      action = CCSequence.createWithTwoActions(scale_action, remove_action)
      if index == 0
        sound_action = CCCallFunc.create do
          CocosDenshion::SimpleAudioEngine.sharedEngine.playEffect(MP3_REMOVE_BLOCK)
        end
        action = CCSpawn.createWithTwoActions(action, sound_action)
      end
      b.runAction(action)
    end
  end

  def move_blocks1(blocks)
    blocks.each_with_index do |b, index|
      x,y = block_tag_to_xy(b.getTag())
      ((y+1)..(BLOCK_MAX_Y-1)).each do |y0|
        block = @bg.getChildByTag(xy_to_block_tag(x,y0))
        if block
          if block.next_y == -1
            block.next_y = y0
            block.next_x = x
          end
          block.next_y -= 1
        end
      end
    end
    run_move_actions(MOVING_TIME_1)

    schedule_once(MOVING_TIME_1) do |a,b|
      move_blocks2
    end
  end

  def move_blocks2
    (0..BLOCK_MAX_X).each do |x|
      if @bg.getChildByTag(xy_to_block_tag(x,0))
        next
      else
        (x...BLOCK_MAX_X).each do |_x|
          (0...BLOCK_MAX_Y).each do |_y|
            tag = xy_to_block_tag(_x,_y)
            block = @bg.getChildByTag(tag)
            if block
              if block.next_x == -1
                block.next_y = _y
                block.next_x = _x
              end
              block.next_x -= 1
            end
          end
        end
      end
    end
    run_move_actions(MOVING_TIME_2)

    schedule_once(MOVING_TIME_2) do |a,b|
      @animating = false
      if gameover?
        highscore = CCUserDefault.sharedUserDefault.getIntegerForKey("highscore", 0)
        if highscore < @score
          CCUserDefault.sharedUserDefault.setIntegerForKey("highscore", @score)
        end

        bg_size = @bg.getContentSize

        @gameover = Sprite.new("gameover.png")
        @gameover.setPosition(ccp(bg_size.width * 0.5, bg_size.height * 0.8))
        @bg.addChild(@gameover, ZORDER[:gameover], TAG[:gameover])

        @layer.setTouchEnabled(false)
      end

      _update_labels
    end
  end

  def run_move_actions(moving_time)
    (0...BLOCK_MAX_X).each do |_x|
      (0...BLOCK_MAX_Y).each do |_y|
        b = @bg.getChildByTag(xy_to_block_tag(_x,_y))
        if b && 0<=b.next_x && 0<=b.next_y
          move_action = CCMoveTo.create(moving_time, blockCCPoint(b.next_x, b.next_y))
          b.runAction(move_action)
          b.setTag(xy_to_block_tag(b.next_x, b.next_y))
          b.next_x = -1
          b.next_y = -1
        end
      end
    end
  end

  def gameover?
    (0...BLOCK_MAX_X).each do |_x|
      (0...BLOCK_MAX_Y).each do |_y|
        block = @bg.getChildByTag(xy_to_block_tag(_x,_y))
        if block
          blocks = find_same_color_neighboring_blocks(block)
          if 0 < blocks.size
            return false
          end
        end
      end
    end
    return true
  end

  def schedule_once(delay, *args, &block)
    scheduler = CCDirector.sharedDirector.getScheduler

    entry_id = scheduler.scheduleScriptFunc(delay, false) do
      scheduler.unscheduleScriptEntry(entry_id)
      block.call(*args)
    end
  end
end

d = CCDirector.sharedDirector
d.setContentScaleFactor(768.0 / d.getWinSize.height)
nyangame = NyanGame.new
d.pushScene(nyangame.scene.cc_object)
