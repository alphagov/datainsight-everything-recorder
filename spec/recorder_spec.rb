require "json"
require "fileutils"

require_relative "spec_helper"
require_relative "../lib/recorder"

describe "Recorder" do
  before(:each) do
    @message = {
      :envelope => {
        :collected_at => DateTime.now.strftime,
        :collector => "visits",
        :_routing_key => "google_analytics.visits.weekly"
      },
      :payload => {
        :value => 700,
        :start_at => "2011-03-28T00:00:00",
        :end_at => "2011-04-04T00:00:00",
        :site => "directgov"
      }
    }.to_json
    @data_dir = "/tmp/datainsight-everything-recorder"
    FileUtils.mkpath(@data_dir)

    @recorder = Recorder.new(@data_dir)
  end

  after(:each) do
    FileUtils.rm_rf(@data_dir)
  end

  def stub_today(new_date)
    Date.stub(:today).and_return(new_date)
  end

  it "should add a message to a file for today" do
    stub_today(Date.new(2012, 5, 5))
    @recorder.process_message({:payload => @message.to_json})

    File.exists?(File.join(@data_dir, "messages-2012-05-05")).should be_true
  end

  it "should write to a new file on a new day" do
    stub_today(Date.new(2012, 5, 5))
    @recorder.process_message({:payload => @message.to_json})
    stub_today(Date.new(2012, 5, 6))
    @recorder.process_message({:payload => @message.to_json})

    File.exists?(File.join(@data_dir, "messages-2012-05-05")).should be_true
    File.exists?(File.join(@data_dir, "messages-2012-05-06")).should be_true
  end

end