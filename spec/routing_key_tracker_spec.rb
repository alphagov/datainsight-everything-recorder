require_relative "spec_helper"
require_relative "../lib/routing_key_tracker"

describe "Routing key tracker" do
  before(:each) do
    @tracker = RoutingKeyTracker.new
    @tracker.stub(:write)
  end
  it "should return all the keys that have been added and their most recent dates" do
    @tracker.notify("foo.bar")
    @tracker.notify("foo.monkey")

    @tracker.keys.keys.sort.should == %w(foo.bar foo.monkey)
  end

  it "should always have the most recent time" do
    DateTime.stub(:now).and_return(DateTime.new(2012, 10, 10, 10, 10, 10))
    @tracker.notify("foo.bar")
    DateTime.stub(:now).and_return(DateTime.new(2012, 10, 10, 10, 10, 20))
    @tracker.notify("foo.monkey")
    DateTime.stub(:now).and_return(DateTime.new(2012, 10, 10, 10, 10, 30))
    @tracker.notify("foo.bar")

    @tracker.keys["foo.monkey"].should == DateTime.new(2012, 10, 10, 10, 10, 20)
    @tracker.keys["foo.bar"].should == DateTime.new(2012, 10, 10, 10, 10, 30)
  end

  it "should write the keys to a json file" do
    @tracker.should_receive(:write)
    DateTime.stub(:now).and_return(DateTime.new(2012, 10, 10, 10, 10, 10))
    @tracker.notify("foo.monkey")
  end
end