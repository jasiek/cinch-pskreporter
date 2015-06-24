require 'cinch'
require 'rexml/document'
require 'net/http'

module Cinch::Plugins
  class PSKReporter
    include Cinch::Plugin

    self.help = "Every 10 minutes, talk to pskreporter.info and post RX reports"

    timer 10, method: :check_pskreporter

    def check_pskreporter
      config[:callsigns].each do |callsign|
        reports = pskreporter_reports(callsign, -10 * 60) # 10 minutes
        msg_reports(reports) if reports.any?
      end
    end

    def pskreporter_reports(callsign, since_when)
      body = Net::HTTP.get("http://retrieve.pskreporter.info/query?senderCallsign=#{callsign}&flowStartSeconds=#{since_when}&rronly=1")
      doc = REXML::Document.new(body)
      doc.xpath("//receptionReports/receptionReport").each do |rr|
        ?
      end
    end
  end
end
