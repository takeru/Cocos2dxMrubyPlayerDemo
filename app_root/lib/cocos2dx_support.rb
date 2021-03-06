module Cocos2dx
  class WrapObjects
    @@instance = nil
    def initialize
      @wrap_objects = {}
    end

    def add(id, wrap_obj)
      @wrap_objects[id] = wrap_obj
      #log "ADD add id=#{id} #{wrap_obj} #{wrap_obj.cc_object} count=#{@wrap_objects.count}"
    end

    def remove(cc_obj)
      wrap_obj = @wrap_objects.delete(cc_obj.m_nLuaID)
      if wrap_obj
        #log "DEL remove id=#{cc_obj.m_nLuaID} #{wrap_obj.class} count=#{@wrap_objects.count}"
        wrap_obj.dispose
      else
        #log "XXX remove id=#{cc_obj.m_nLuaID}"
      end
    end

    def get(id)
      @wrap_objects[id]
    end

    def self.instance
      @@instance ||= WrapObjects.new
    end

    def self.add(id, wrap_obj)
      instance.add(id, wrap_obj)
    end

    def self.remove(cc_obj)
      instance.remove(cc_obj)
    end

    def self.get(id)
      instance.get(id)
    end
  end

  Callback.remove_script_object do |cc_obj|
    WrapObjects.remove(cc_obj)
  end

  class Node
    attr_reader :cc_object

    def initialize(*args)
      @cc_class_name ||= 'CC' + self.class.to_s.split("::").last
      unless @cc_constructor_name
        @cc_constructor_name = 'create'
        if 1<=args.size && args[0].kind_of?(Symbol)
          suffix = args.shift
          @cc_constructor_name += suffix.to_s
        end
      end
      @cc_class = Cocos2dx.const_get(@cc_class_name)
      args = _wrap_object_to_cc_object(args)
      @cc_object = @cc_class.send(@cc_constructor_name, *args)
      @cc_object.m_nLuaID = @cc_object.m_uID
      WrapObjects.add(@cc_object.m_uID, self)
    end

    def dispose
      @cc_object = nil
    end

    def _wrap_object_to_cc_object(args)
      args.map do |arg|
        if arg.kind_of?(Node)
          arg.cc_object
        elsif arg.kind_of?(Array)
          _wrap_object_to_cc_object(arg)
        else
          arg
        end
      end
    end

    def method_missing(method, *args, &block)
      unless @cc_object
        raise "#{self} is not active."
      end

      args = _wrap_object_to_cc_object(args)

      ret = @cc_object.send(method, *args, &block)

      if ret.kind_of?(CCObject)
        tmp = WrapObjects.get(ret.m_nLuaID)
        ret = tmp if tmp
      end

      return ret
    end

    def to_s
      super
    end

    def inspect
      super
    end
  end

  class NodeRGBA < Node
  end

  class Sprite < NodeRGBA
    def self.createWithTexture(*args)
      new(:WithTexture, *args)
    end
  end

  class Layer < Node
  end

  class Scene < Node
  end

  class SpriteBatchNode < Node
  end

  class LabelTTF < Sprite
  end

  class LabelBMFont < SpriteBatchNode
  end

  class LayerRGBA < Layer
  end

  class Menu < LayerRGBA
    def self.createWithItem(item)
      new(:WithItem, item)
    end
  end

  class MenuItem < NodeRGBA
  end

  class MenuItemSprite < MenuItem
  end

  class MenuItemImage < MenuItemSprite
  end

  class MenuItemLabel < MenuItem
  end

  class MenuItemFont < MenuItemLabel
  end

  class DrawNode < Node
  end

  def self.schedule_once(delay, *args, &block)
    scheduler = CCDirector.sharedDirector.getScheduler
    entry_id = scheduler.scheduleScriptFunc(delay, false) do
      scheduler.unscheduleScriptEntry(entry_id)
      block.call(*args)
    end
  end

  class WebSocketLogger
    # https://github.com/takeru/websocket-log-receiver
    def initialize(url)
      @queue = []
      @connected = false
      @ws = WebSocket.create(url) do |event,data|
        # puts "WebSocketLogger event=#{event} data=#{data.inspect}"
        case event
        when "open"
          @connected = true
          flush
        when "close"
          @connected = false
          @ws.close
          @ws = nil
        end
      end
    end
    def log(s)
      @queue << s
      flush if @connected
    end
    def flush
      while s = @queue.shift
        @ws.send(s)
      end
    end
    def close
      @ws.close if @ws
    end
  end

  class LogLayer < Layer
    def initialize(font_height=20)
      @cc_class_name = 'CCLayer'
      super

      @win_size = CCDirector.sharedDirector.getWinSize
      @font_height = font_height
      @logs_max = (@win_size.height / @font_height).floor
      @label = LabelTTF.new("", 'Courier New', @font_height, cCSizeMake(@win_size.width,@win_size.height), KCCTextAlignmentLeft, KCCVerticalTextAlignmentTop)
      @label.setAnchorPoint(ccp(0,0))
      @label.setPosition(0,0)
      addChild(@label)
      @logs = []
    end
    def log(s)
      @logs.push(s)
      @logs.shift if @logs_max < @logs.size
      @label.setString(@logs.join("\n"))
    end
    def close
      # nop
    end
  end

  class Logger
    @@loggers = []
    def self.add(l)
      @@loggers.push(l)
    end
    def self.cleanup
      @@loggers.each do |l|
        l.close
      end
    end
    def self.log(s)
      @@loggers.each do |l|
        l.log(s)
      end
    end
  end

  Callback.uncaught_exception do |e,bt|
    s = "* #{e.inspect}\n"
    bt.each do |b|
      s << "  - #{b}\n"
    end if bt
    log(s)
  end

  Callback.before_shutdown do
    log("before_shutdown")
    Cocos2dx::Logger.cleanup
    WebSocket.cleanup
  end

  class WebSocket
    class << self
      def active_sockets
        @active_sockets ||= []
      end
      alias :create_with_autoclose :create unless method_defined?(:create_with_autoclose)
      def create(url, &block)
        ws = create_with_autoclose(url, &block)
        active_sockets << ws
        ws
      end
      def cleanup
        active_sockets.dup.each do |ws|
          ws.close
        end
      end
    end
    alias :close_with_autoclose :close unless method_defined?(:close_with_autoclose)
    def close
      WebSocket.active_sockets.delete(self)
      close_with_autoclose
    end
  end

  class CCSize
    def inspect
      to_s
    end
    def to_s
      "CCSize(w=#{width},h=#{height})"
    end
  end

  class CCRect
    def inspect
      to_s
    end
    def to_s
      "CCRect(origin=#{origin},size=#{size})"
    end
  end

  class CCPoint
    def inspect
      to_s
    end
    def to_s
      "CCRect(x=#{x},y=#{y})"
    end
  end

  CCSizeZero = cCSizeMake(0,0)
end

module ::Kernel
  def log(s)
    puts s
    Cocos2dx::Logger.log(s)
  end
  def reboot!
    Cocos2dxMrubyPlayer.reboot!
  end
end
