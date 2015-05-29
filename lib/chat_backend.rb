require 'faye/websocket'
require 'thread'
require 'redis'
require 'json'
require 'erb'

class ChatBackend
  KEEPALIVE_TIME = 15
  CHANNEL = 'chat-demo'

  def initialize app
    @app = app
    @clients = []
    uri = URI.parse('redis://localhost:6379')
    @redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
    Thread.new do
      redis_sub = Redis.new(host: uri.host, port: uri.port, password: uri.password)
      redis_sub.subscribe(CHANNEL) do |on|
        on.message do |channel, msg|
          @clients.each { |ws| ws.send msg }
        end
      end
    end
  end

  def call env
    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env, nil, { ping: KEEPALIVE_TIME })

      ws.on :open do |event|
        p [:open, ws.object_id]
        @clients << ws
      end

      ws.on :message do |event|
        p [:message, event.data]
        @redis.publish(CHANNEL, sanitize(event.data))
      end

      ws.on :close do |event|
        p [:close, ws.object_id, event.code, event.reason]
        @clients.delete ws
        ws = nil
      end
      ws.rack_response
    else
      @app.call(env)
    end
  end

  private
    def sanitize message
      json = JSON.parse message
      json.each { |k, v| json[k] = ERB::Util.html_escape v }
      JSON.generate json
    end
end

