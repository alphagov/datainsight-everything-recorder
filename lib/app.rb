require "bundler/setup"
Bundler.require(:default, :exposer)
require "json"

helpers Datainsight::Logging::Helpers

configure do
  enable :logging
  unless test?
    Datainsight::Logging.configure(:type => :exposer)
  end
end

get '/routing-keys' do
  content_type :json
  data_object.to_json
end

def data_object
  {meta:'foo', topics:'bar'}
end

error do
  logger.error env['sinatra.error']
end
