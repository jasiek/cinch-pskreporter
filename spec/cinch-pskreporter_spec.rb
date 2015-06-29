require 'spec_helper'

describe Cinch::Plugins::PSKReporter do
  include Cinch::Test
  include Cinch::Helpers

  let :bot do
    make_bot
  end

  before :each do
    @plugin = Cinch::Plugins::PSKReporter.new(bot)
    allow(@plugin).to receive(:config).and_return({ 
      watchers: { 
        'lhs-radio' => ['2e0kef', 'm0hsl'],
        'hamradio' => ['k1jt']
      }})
  end

  it "should generate a set of requests, one for each callsign" do
    %w{2e0kef m0hsl k1jt}.each do |callsign|
      expect(@plugin).to receive(:pskreporter_reports).with(callsign, -600).once.and_return([])
    end
    expect(@plugin).to receive(:msg_reports).never

    @plugin.check_pskreporter
  end

  it "should send a message to the channel for each report" do
    reports = [].tap do |reports|
      REXML::Document.new(File.read('spec/data/reports.xml')).each_element("//receptionReport") do |element|
        reports << Hashie::Mash.new(element.attributes.symbolize_keys)
      end
    end

    expect(@plugin).to receive(:pskreporter_reports).with('2e0kef', anything).and_return(reports)
    expect(@plugin).to receive(:pskreporter_reports).with(anything, anything).and_return([]).twice
    expect(Channel('lhs-radio')).to receive(:send).once
    expect(Channel('hamradio')).to receive(:send).never

    @plugin.check_pskreporter
  end

  it "should convert locations to coordinates" do
    lat, lng = Cinch::Plugins::PSKReporter.coords_from_maidenhead("JO02ma")
    expect(lat).to be_within(0.1).of(52)
    expect(lng).to be_within(0.1).of(1)
  end

  it "should calculate the great circle distance between two points" do
    # Distance between ORD and NRT
    expect(Cinch::Plugins::PSKReporter.distance([41.978611, -87.904722], [35.765278, 140.385556])).to be_within(30).of(10097)
  end
end
