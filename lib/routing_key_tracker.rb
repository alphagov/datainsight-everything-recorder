require "date"
require "json"

class RoutingKeyTracker
  PATH = "/var/tmp/datainsight-everything-recorder.json"

  def notify(routing_key)
    keys[routing_key] = DateTime.now
    File.open(PATH,"w+") do |file|
      file.write(keys.to_json)
    end
  end

  def keys
    @keys ||= Hash.new
  end
end