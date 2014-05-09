$text = <<END
This file is: Dropbox/.../Cocos2dxMrubyPlayer/boot.rb

App boot sequence:
  First, $DBX/boot.rb is exists, will be tried to load.
  Second, (if $DBX/boot.rb does not exist or error,) $APP/boot.rb will be loaded.
  $DBX/ : DropBox app directory, name is 'Cocos2dxMrubyPlayer'.
  $APP/ : App bundled example code directory. This is 'app_root' in github.

You can edit this file on dropbox, then file on device is updated too.

All code examples are here: https://github.com/takeru/Cocos2dxMrubyPlayerDemo

Tap to go menu.
END

def intro
  Cocos2dxMrubyPlayer.load("$APP/lib/cocos2dx_support.rb")
  include Cocos2dx

  win_size = CCDirector.sharedDirector.getWinSize
  scene = Scene.new
  layer = Layer.new
  layer.registerScriptTouchHandler do |eventType, touch|
    Cocos2dxMrubyPlayer.load("$DBX/app_root/demo/menu.rb")
  end
  layer.setTouchMode(KCCTouchesOneByOne)
  layer.setTouchEnabled(true)

  font = nil
  size = 30
  label = LabelTTF.new($text, font, size, win_size, KCCTextAlignmentLeft, KCCVerticalTextAlignmentTop)
  label.setPosition(win_size.width/2,win_size.height/2)
  layer.addChild(label)
  scene.addChild(layer)

  d = CCDirector.sharedDirector
  d.pushScene(scene.cc_object)
end

# very basic example.
def hello
  include Cocos2dx
  fu = CCFileUtils.sharedFileUtils
  fu.addSearchPath ""

  d = CCDirector.sharedDirector
  win_size = d.getWinSize
  sprite = CCSprite.create("Icon-114.png")
  sprite.setPosition(win_size.width*0.5, win_size.height*0.5)

  menu = CCMenu.create
  menu.setPosition(0,0)
  item = CCMenuItemFont.create("reboot!")
  item.setPosition(win_size.width*0.5, win_size.height*0.25)
  item.registerScriptTapHandler do
    Cocos2dxMrubyPlayer.reboot!
  end
  menu.addChild(item)

  scene = CCScene.create
  scene.addChild(sprite)
  scene.addChild(menu)
  d.pushScene(scene)
end

# same as app menu. but code is loaded from dropbox.
# Please checkout from https://github.com/takeru/Cocos2dxMrubyPlayerDemo
def menu_app_on_dropbox
  Cocos2dxMrubyPlayer.load("$DBX/app_root/demo/menu.rb")
end

def goto_app_boot
  raise "!!! goto $APP/boot.rb !!!"
end

# call one of methods above.
intro
#hello
#menu_app_on_dropbox
#goto_app_boot
