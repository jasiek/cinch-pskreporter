require 'cinch'

module Cinch::Plugins
  class PSKReporter
    include Cinch::Plugin

    self.help = "Every 10 minutes, talk to pskreporter.info and post RX reports"
  end
end
