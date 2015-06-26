require 'spec_helper'

describe Cinch::Plugins::PSKReporter do
  include Cinch::Test

  before :all do
    @bot = make_bot(Cinch::Plugins::PSKReporter,
                    { watchers: { '2e0kef' => 'lhs-radio' } })
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
