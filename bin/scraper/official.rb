#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'json'
require 'pry'

class MemberList
  # details for an individual member (really JSON)
  class Member < Scraped::HTML
    PREFIXES = %w[Msc prof. dr mr].freeze

    field :name do
      PREFIXES.reduce(noko['title']) { |current, prefix| current.sub("#{prefix} ", '') }
    end

    field :position do
      return noko['function'] unless noko['function'] == 'Minister'

      body.sub('Ministry', 'Minister')
    end

    private

    def body
      noko['organizational_unit']['title']
    end
  end

  # The page listing all the members
  class Members < Scraped::HTML
    field :members do
      slotables.map { |member| fragment(member => Member).to_h }
    end

    private

    def json
      # Ugh! Inlined JSON (with quotes replaced)
      @json = JSON.parse(noko.css('#gov-state').text.gsub('&q;', '"'))
    end

    def slotables
      json.values.first['body']['data']['modules'].last['slotables']
    end
  end
end

file = Pathname.new 'html/official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
