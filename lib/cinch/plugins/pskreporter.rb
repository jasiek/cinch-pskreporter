require 'cinch'
require 'rexml/document'
require 'net/http'
require 'hashie/mash'

class Hash
  def symbolize_keys
    self.inject({}) do |h, (key, value)|
      h.update(key.to_sym => value)
    end
  end
end

module Cinch::Plugins
  class PSKReporter
    include Cinch::Plugin

    self.help = "Every 10 minutes, talk to pskreporter.info and post RX reports"

    timer 600, method: :check_pskreporter

    def check_pskreporter
      config[:watchers].each do |channel, callsigns|
        callsigns.each do |callsign|
          reports = pskreporter_reports(callsign, -10 * 60) # 10 minutes
          msg_reports(channel, reports) if reports.any?
        end
      end
    end

    def pskreporter_reports(callsign, since_when)
      body = Net::HTTP.get(URI.parse "http://retrieve.pskreporter.info/query?senderCallsign=#{callsign}&flowStartSeconds=#{since_when}&rronly=1&rand=#{rand}")
      debug body
      doc = REXML::Document.new(body)
      [].tap do |reports|
        doc.each_element("//receptionReport") do |element|
          reports << Hashie::Mash.new(element.attributes.symbolize_keys)
        end
      end
    end

    def msg_reports(channel, reports)
      reports.each do |report|
        Channel(channel).send(report_text(report))
      end
    end

    def report_text(r)
      frequency = r.frequency.to_f / 1000
      if d = self.class.distance(*[r.senderLocation, r.receiverLocation].map { |loc| self.class.coords_from_maidenhead(loc) })
        "#{r.receiverCallsign} (#{r.receiverLocation}) heard #{r.senderCallsign} (#{r.senderLocation}) = #{d} km @ #{frequency} kHz using #{r.mode}"
      else
        "#{r.receiverCallsign} heard #{r.senderCallsign} @ #{frequency} kHz using #{r.mode}"
      end
    end

    def self.distance(c1, c2)
      return nil unless c1 && c2

      c1 = deg2rad(c1)
      c2 = deg2rad(c2)
      
      radius = 6371 # km
      delta = (c1[1] - c2[1]).abs
      radius * Math.acos(Math.sin(c1[0]) * Math.sin(c2[0]) + Math.cos(c1[0]) * Math.cos(c2[0]) * Math.cos(delta))
    end

    def self.coords_from_maidenhead(grid)
      return nil if grid.nil?

      xxx, yyy, xx, yy, x, y = grid.upcase.split(//)
      
      lon = (xxx.ord - 'A'.ord) * 20 - 180 + (xx.ord - '0'.ord) * 2
      lat = (yyy.ord - 'A'.ord) * 10 - 90 + (yy.ord - '0'.ord) * 1

      if x && y
        lon += (x.ord - 'A'.ord) * 1.0/12
        lat += (y.ord - 'A'.ord) * 1.0/24
      end

      [lat, lon]
    end

    def self.deg2rad(coords)
      coords.map { |c| c * Math::PI / 180 }
    end
  end
end
