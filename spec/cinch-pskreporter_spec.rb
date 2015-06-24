require 'spec_helper'

describe Cinch::Plugins::PSKReporter do
  include Cinch::Test

  before :all do
    @bot = make_bot(Cinch::Plugins::PSKReporter,
                    { callsigns: ['2e0kef'],
                      irc_username: 'DUMMY',
                      irc_password: 'DUMMY' })
  end

  it "should attempt to contact pskreporter and retrieve reception reports for 2E0KEF" do
    # TODO
  end
end
