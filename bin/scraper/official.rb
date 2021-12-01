#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'json'
require 'pry'

class MemberList
  class Member
    def name
      Name.new(full: noko['title'], prefixes: %w[Msc prof. dr mr MS MBA PhD]).short
    end

    def position
      return noko['function'] unless noko['function'] == 'Minister'

      body.sub('Ministry', 'Minister')
    end

    private

    def body
      noko['organizational_unit']['title']
    end
  end

  class Members
    def json
      # Ugh! Inlined JSON (with quotes replaced)
      @json = JSON.parse(noko.css('#gov-state').text.gsub('&q;', '"'))
    end

    def member_container
      json.values.first['body']['data']['modules'].last['slotables']
    end
  end
end

file = Pathname.new 'html/official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
