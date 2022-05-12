#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'Minister'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[color name start end].freeze
    end

    def empty?
      (tds[1].text == tds[2].text) || too_early?
    end

    def ignore_before
      1998
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
