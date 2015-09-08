class Fluent::EventCounterOutput < Fluent::BufferedOutput
  Fluent::Plugin.register_output('eventcounter', self)
  def initialize
    super
    require 'redis'
  end

  config_param :emit_only, :bool, :default => false
  config_param :emit_to, :string, :default => 'debug.events'

  config_param :redis_host, :string, :default => 'localhost'
  config_param :redis_port, :integer, :default => 6379
  config_param :redis_password, :string, :default => nil, :secret => true
  config_param :redis_db_number, :integer, :default => 0
  config_param :redis_output_key, :string, :default => ''

  config_param :input_tag_exclude, :string, :default => ''
  config_param :capture_extra_if, :string, :default => nil
  config_param :capture_extra_replace, :string, :default => ''
  config_param :debug_emit, :bool, :default => false

  config_param :count_key, :string # REQUIRED 

  attr_accessor :counts

  def configure(conf)
    super
    @capture_extra_replace = Regexp.new(@capture_extra_replace) if @capture_extra_replace.length > 0
  end

  def start
    super
    @redis = Redis.new(
        host: @redis_host,
        port: @redis_port,
        password: @redis_password,
        thread_safe: true,
        db: @redis_db_number
      ) unless @emit_only
  end

  def format(tag, time, record)
    return '' unless record[@count_key]

    if @capture_extra_if && record[@capture_extra_if]
      extra = record[@capture_extra_if].gsub(@capture_extra_replace, '')
      [tag.gsub(@input_tag_exclude,""), [record[@count_key], extra].compact.join(':')].to_json + "\n"
    else
      [tag.gsub(@input_tag_exclude,""), record[@count_key]].to_json + "\n"
    end
  end

  def write(chunk)
    counts = Hash.new {|hash, key| hash[key] = Hash.new {|h,k| h[k] = 0 } }
    chunk.open do |io|
      items = io.read.split("\n")
      items.each do |item|
        key, event = JSON.parse(item)
        counts[key][event] += 1 
      end
    end

    @redis.pipelined do
      counts.each do |tag,events|
        events.each do |event, c|
          redis_key = [@redis_output_key,tag].join(':')
          @redis.hincrby(redis_key, event, c.to_i)
        end        
      end
    end unless @emit_only

    if @emit_only || @debug_emit
      counts.each do |tag, events|
        Fluent::Engine.emit(@emit_to, Time.now, tag => events)
      end
    end

  end
end