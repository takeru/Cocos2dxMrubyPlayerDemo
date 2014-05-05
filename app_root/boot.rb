begin
  Cocos2dx::CCFileUtils.sharedFileUtils.removeAllPaths
  Cocos2dx::CCFileUtils.sharedFileUtils.purgeCachedEntries
  Cocos2dx::CCTextureCache.sharedTextureCache.removeAllTextures
  Cocos2dxMrubyPlayer.load("$DB/boot.rb")
rescue => e
  puts "Failed fo load $DB/boot.rb e=#{e.inspect}"
  Cocos2dxMrubyPlayer.load("$APP/demo/menu.rb")
end

