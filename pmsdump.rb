#!/usr/bin/ruby
# frozen_string_literal: true

require 'httparty'
require 'awesome_print'
require 'csv'

require './pmsauth'

class Pms
  include HTTParty
  base_uri 'https://pms.ikikier.io/api/'
  basic_auth PMS_USER, PMS_PASS

  def parties
    self.class.get('/parties/')
  end

  def compos(party)
    self.class.get("/party/#{party}/compos/")
  end

  def entries(party, compo)
    self.class.get("/party/#{party}/compo/#{compo}/entries/")
  end
end

def escape(str)
  str.gsub(/ /, '_').gsub(/[^A-Za-z0-9]/, '')
end

pms = Pms.new
@party = 'asm19'
compos = pms.compos(@party).parsed_response

yt = []

compos.each do |compo|
  next if ARGV[0] && ARGV[0] != compo['slug']

  puts compo['name']
  puts '=' * compo['name'].length
  puts

  pms.entries(@party, compo['slug']).parsed_response.each do |entry|
    fn = "#{compo['slug']}_#{escape(entry['name'])}_by_#{escape(entry['credits'])}"
    puts "#{fn}  (#{entry['name']})"
    # yt << 'youtube-upload "' + fn + ".mp4\" -t '" + entry['name'] + " by " + entry['credits'] + "' --privacy=private | tee \"" + fn + ".tube.txt\""
    # yt << 'curl -n -XPUT -H"Content-Type: text/plain" -d preview_link=https://www.youtube.com/watch\?v=$(cat "'+fn+'.tube.txt") https://pms.ikikier.io/api/party/' + @party + '/compo/' + compo['slug'] + '/entry/' + entry['id'].to_s + '/'
    # ap entry
    yt << ['', compo['slug'], entry['id'], fn, "#{entry['name']} by #{entry['credits']}"]
  end
  puts
  puts
end

# puts yt.join("\n")

x = CSV.generate do |csv|
  yt.each do |y|
    csv << y
  end
end
puts x

# ="curl -n -XPUT -H'Content-Type: text/plain' -d preview_link=https://www.youtube.com/watch\?v=" & A1 & " https://pms.ikikier.io/api/party/asm19/compo/" & B1 & "/entry/" & C1 & "/"
