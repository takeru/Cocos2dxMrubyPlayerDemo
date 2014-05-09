include Cocos2dx
fu = CCFileUtils.sharedFileUtils
fu.addSearchPath("")
#fu.addSearchPath(fu.fullPathFromRelativeFile("", __FILE__))
#puts "SearchPaths:#{fu.getSearchPaths}"
#Cocos2dxMrubyPlayer.load("../../lib/cocos2dx_support.rb")
#Cocos2dx::Logger.add(Cocos2dx::WebSocketLogger.new("ws://192.168.0.6:9292"))

puts 'hello!!'

d = CCDirector.sharedDirector
win_size = d.getWinSize
sprite = CCSprite.create("Icon-114.png")
sprite.setPosition(win_size.width*0.5, win_size.height*0.5)

menu = CCMenu.create
menu.setPosition(0,0)
item = CCMenuItemFont.create("reboot!")
item.setPosition(win_size.width*0.5, win_size.height*0.25)
item.registerScriptTapHandler do
  puts "*** reboot! ***"
  Cocos2dxMrubyPlayer.reboot!
end
menu.addChild(item)

scene = CCScene.create
scene.addChild(sprite)
scene.addChild(menu)
d.pushScene(scene)
