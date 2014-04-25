class Kani < Sprite
  def initialize
    @cc_class_name = 'CCSprite'
    super($resources_path + "kani.png")
    #registerScriptHandler do |node, action|
    #  case action
    #  when Cocos2d::KCCNodeOnEnter
    #    p "OnEnter"
    #  when Cocos2d::KCCNodeOnExit
    #    p "OnExit"
    #  when Cocos2d::KCCNodeOnEnterTransitionDidFinish
    #    p "OnEnterTransitionDidFinish"
    #  when Cocos2d::KCCNodeOnExitTransitionDidStart
    #    p "OnExitTransitionDidStart"
    #  when Cocos2d::KCCNodeOnCleanup
    #    p "OnCleanup"
    #  end
    #end
    self.setAnchorPoint(Cocos2d::ccp(0,0))
    @reset_count = 0
    reset
  end

  def _update(dt)
    @x -= @speed * RATE * dt
    setPosition(@x, 20)
  end

  attr_reader :x
  attr_accessor :state

  def reset
    case @reset_count
    when 0..2
      @speed = 5
    when 2..4
      @speed = 6
    when 4..6
      @speed = 3 + rand(6)
    else
      @speed = 3 + rand(10)
    end
    @reset_count += 1
    @x = 568 + rand(1000)
    @state = 'init'
    _update(0)
  end
end
