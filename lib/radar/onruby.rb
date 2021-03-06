require 'ruby_meetup'
require 'open-uri'

module Radar
  class Onruby < Base
    include ActionView::Helpers::TextHelper

    def next_events
      json = JSON.parse(open("#{base_url}/events.json").read)
      json.map do |event|
        cleanup_event(event)
      end
    end

    def cleanup_event(event)
      result = {
         id: event["id"],
         url: "#{base_url}/events/#{event["id"]}",
         title: event["name"],
         description: description(event),
         time: Time.parse(event["date"]),
         venue: parse_location(event["location"])
      }
      result
    end

    def base_url
      "http://#{URI.parse(@radar_setting.url).host}"
    end

    def description(event)
      desc = simple_format(event["description"])
      event["topics"].each do |topic|
        desc += "<p>#{topic["name"]} - #{topic["user"]["name"]}</p>".html_safe
        desc += simple_format(topic["description"])
      end
      desc
    end

    def parse_location(location)
      if location
        "#{location["name"]}, #{location["street"]} #{location["house_number"]}, #{location["zip"]} #{location["city"]}, #{location["url"]}"
      end
    end

    private

    # This method is needed for the simple_format helper
    def raw(string)
      string.html_safe
    end

  end
end
