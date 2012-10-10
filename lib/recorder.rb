require 'bundler/setup'
Bundler.require(:default, :recorder)
require_relative "routing_key_tracker"

class Recorder
  AMQP_ROUTING_KEY = "#"
  AMQP_EXCHANGE = "datainsight"
  AMQP_QUEUE = "everything"

  def initialize(data_dir=nil)
    @data_dir = data_dir || "/var/data/datainsight/everything"
  end

  def run
    queue.subscribe do |msg|
      begin
        logger.debug { "Received a message: #{msg}"}
        process_message(msg)
        tracker.notify(msg[:delivery_details][:routing_key])
      end
    end
  end

  def process_message(msg)
    file.write("#{msg[:payload]}\n")
  end

  private

  def tracker
    @tracker ||= RoutingKeyTracker.new
  end

  def queue
    @queue ||= create_queue
  end

  def create_queue
    client = Bunny.new
    client.start
    queue = client.queue(AMQP_QUEUE)
    exchange = client.exchange(AMQP_EXCHANGE, :type => :topic)

    queue.bind(exchange, :key => AMQP_ROUTING_KEY)
    logger.info("Bound to #{AMQP_ROUTING_KEY}, listening for events")

    queue
  end

  def file
    if @current_day != Date.today
      if @current_file
        @current_file.close()
      end
      @current_day = Date.today
      @current_file = File.open(File.join(@data_dir, "messages-#@current_day"), "a+")
    end
    @current_file
  end
end