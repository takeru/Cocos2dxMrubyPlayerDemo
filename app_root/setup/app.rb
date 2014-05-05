class SetupApp
  attr_reader :scene
  def initialize
    _create_scene
  end

  def _create_scene
    @win_size = CCDirector.sharedDirector.getWinSize
    @layer = Layer.new

    account = Cocos2dxMrubyPlayer::DropBox.account
    if account
      text = "DropBox: #{account[:display_name]}"
    else
      text = "DropBox: (Not linked)"
    end
    font = "Marker Felt"
    size = 50
    label = LabelTTF.new(text, font, size)
    label.setPosition(@win_size.width/2, @win_size.height-100)
    @layer.addChild(label)

    menu = Menu.new
    menu.setPosition(0,0)
    if account
      item = MenuItemFont.new("Unlink DropBox")
      item.registerScriptTapHandler do
        Cocos2dxMrubyPlayer::DropBox.unlink
        reboot!
      end
    else
      item = MenuItemFont.new("Link DropBox")
      item.registerScriptTapHandler do
        Cocos2dxMrubyPlayer::DropBox.link
        reboot!
      end
    end
    item.setFontSizeObj(50)
    item.setPosition(@win_size.width/2, @win_size.height-200)
    menu.addChild(item)

    # back
    item2 = MenuItemFont.new("Back")
    item2.registerScriptTapHandler do
      reboot!
    end
    item2.setFontSizeObj(50)
    item2.setPosition(@win_size.width/2, @win_size.height-300)
    menu.addChild(item2)

    @layer.addChild(menu)

    @scene = Scene.new
    @scene.addChild(@layer)
  end
end

begin
  d = Cocos2dx::CCDirector.sharedDirector
  view = Cocos2dx::CCEGLView.sharedOpenGLView
  frame_size = view.getFrameSize
  view.setDesignResolutionSize(frame_size.width, frame_size.height, Cocos2dx::KResolutionExactFit)
  d.setDisplayStats(false)
  app = SetupApp.new
  d.pushScene(app.scene.cc_object)
rescue => e
  log "ERROR: #{([e.inspect]+e.backtrace).join("\n  ")}"
end