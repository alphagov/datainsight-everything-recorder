require 'bundler/setup'
Bundler.require(:default, :recorder)

class Recorder
  AMQP_ROUTING_KEY = "#"
  AMQP_EXCHANGE = "datainsight"
  AMQP_QUEUE = "everything"

  def run
    queue.subscribe do |msg|
      begin
        logger.debug { "Received a message: #{msg}"}
        process_message(msg)
      end
    end
  end

  def process_message(msg)
    file.write("#{msg[:payload]}\n")
  end

  private

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
      @current_file = File.open("/var/data/datainsight/everything/messages-#@current_day", "w+")
    end
    @current_file
  end
end