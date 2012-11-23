require "bundler/setup"
Bundler.require(:default, :exposer)
require "json"
require_relative "routing_key_tracker"
require_relative "initializers"

helpers Datainsight::Logging::Helpers

use Airbrake::Rack
enable :raise_errors

configure do
  enable :logging
  unless test?
    Datainsight::Logging.configure(:type => :exposer)
  end
end

get '/routing-keys' do
  content_type :json
  begin
    File.read(RoutingKeyTracker::PATH)
  rescue
    {}.to_json
  end
end

error do
  logger.error env['sinatra.error']
end
