begin
  Cocos2dx::CCFileUtils.sharedFileUtils.removeAllPaths
  Cocos2dx::CCFileUtils.sharedFileUtils.purgeCachedEntries
  Cocos2dx::CCTextureCache.sharedTextureCache.removeAllTextures
  Cocos2dxMrubyPlayer.load("$DBX/boot.rb")
rescue => e
  puts "Failed fo load $DBX/boot.rb e=#{e.inspect}"
  Cocos2dxMrubyPlayer.load("$APP/demo/menu.rb")
end

