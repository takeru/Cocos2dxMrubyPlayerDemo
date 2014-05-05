class Player < Sprite
  def initialize
    @cc_class_name = 'CCSprite'
    tex = CCTextureCache.sharedTextureCache.addImage("vx_chara03_a.png")
    rect = cCRectMake(0,0,0,0)
    super(:WithTexture, tex, rect)

    self.setAnchorPoint(ccp(0,0))

    @count = 0
    @y     = 0
    @vy    = 0
    @ay    = 0.6
    @jump_count = 0
  end

  def _update(dt)
    @count += 1
    _setTexturePosition((@count/10).floor % 3, 2)

    @vy -= @ay * RATE * dt
    @y  += @vy * RATE * dt
    if @y <= 0
      @y  = 0
      @vy = 0
      @ay = 0.6
      @jump_count = 0
    end

    setPosition(80, 20+@y)
  end

  def jump_begin
    if @vy==0 || @jump_count <= 1
      @jump_count += 1
      @vy = 15
      true
    else
      false
    end
  end

  def jump_end
    if 0 < @vy
      @ay = 1.0
    end
  end

  def _setTexturePosition(tx,ty)
    w = 384/12
    h = 384/ 8
    rect = cCRectMake(w*tx, h*ty, w, h)
    setTextureRect(rect)
  end
end
