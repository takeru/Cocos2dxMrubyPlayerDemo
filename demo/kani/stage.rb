class Hash
  def method_missing(method, *args)
    if self.key?(method.to_sym)
      self[method.to_sym]
    else
      super
    end
  end
end

class Stage < Layer
  def initialize
    @cc_class_name = 'CCLayer'
    super
    @score = 0

    @win_size = CCDirector.sharedDirector.getWinSize

    self.registerScriptTouchHandler do |eventType, touch|
      case eventType
      when CCTOUCHBEGAN
        onTouchBegan(touch)
      when CCTOUCHEND
        onTouchEnd(touch)
      end
    end
    self.setTouchMode(KCCTouchesOneByOne)
    self.setTouchEnabled(true)

    @player = Player.new
    self.addChild(@player, zorder.player)

    @bgs = [
      [0,   0, 0.0],
      [1,   0, 0.2],
      [1, 568, 0.2],
      [2,   0, 1.0],
      [2, 568, 1.0],
      [3,   0, 5.0],
      [3, 568, 5.0]
      ].map do |n, x, speed|
      bg = Bg.new($resources_path + "main_bg_0#{n}.png", x, speed)
      self.addChild(bg, zorder.send("bg#{n}"))
      bg
    end

    @kanis = []
    3.times do
      kani = Kani.new
      self.addChild(kani, zorder.kani)
      @kanis << kani
    end

    self.scheduleUpdateWithPriorityLua(1) do |dt,node|
      self.update(dt)
    end
  end

  def zorder
    @zorder ||= {
      :bg0    => 100,
      :bg1    => 101,
      :bg2    => 102,
      :bg3    => 103,
      :kani   => 200,
      :player => 300,
    }
  end

  def onTouchBegan(touch)
    if @player.jump_begin
      CocosDenshion::SimpleAudioEngine.sharedEngine.playEffect($resources_path + "complete.wav")
    end
    return false
  end

  def onTouchEnd(touch)
    @player.jump_end
  end

  def update(dt)
    @player._update(dt)
    @kanis.each do |kani|
      kani._update(dt)
      if kani.x < -100
        kani.reset
        @score += 1
        #refresh_score
        CocosDenshion::SimpleAudioEngine.sharedEngine.playEffect($resources_path + "blip.wav")
      end
      if @player.boundingBox.intersectsRect(kani.boundingBox)
        gameover
        return
      end
    end
    @bgs.each do |bg|
      bg._update(dt)
    end
  end

  def gameover
    CocosDenshion::SimpleAudioEngine.sharedEngine.playEffect($resources_path + "reset.wav")

    if true
      reboot!
    else
      d = CCDirector.sharedDirector
      app = KaniApp.new
      d.replaceScene(app.scene.cc_object)
    end
  end
end
