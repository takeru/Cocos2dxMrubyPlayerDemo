puts 'hello!!'

include Cocos2dx

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
