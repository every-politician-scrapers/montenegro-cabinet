#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'json'
require 'pry'

class MemberList
  class Member
    # These are hidden behind "..." on the site, so sub them in until they fix that.
    HIDDEN_POSITION = {
      'Jovana Marović'    => ' «European Affairs»',
      'Vladimir Joković'  => ' «Agriculture, Forestry and Water Management»',
      'Raško Konjević'    => ' «Defence»',
      'Ervin Ibrahimović' => ' «Capital Investments»',
    }.freeze

    def name
      Name.new(full: title, prefixes: %w[Msc prof. dr mr MS MBA PhD]).short
    end

    def position
      ministerial_position.gsub('...') { HIDDEN_POSITION[name] }.split(/ i (?=ministar)/).map(&:tidy)
    end

    private

    def body
      noko['organizational_unit']['title']
    end

    def function
      return noko['function'] if position?

      noko['title'].split(', ', 2).last
    end

    def title
      return noko['title'] if position?

      noko['title'].split(', ', 2).first
    end

    def position?
      !noko['function'].to_s.empty?
    end

    def ministerial_position
      return function unless function =~ /^ministar(ka)?$/

      body.sub('Ministarstvo', function)
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

file = Pathname.new 'official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
