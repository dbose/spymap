#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'
require 'builder'
require './crawler'

domains = {
  # :wedding => {
  #   :domain => "http://www.wedding.com.au",
  #   :white_lists => [
  #         /\/wedding-news\//i,
  #         /\/special-offers\//i,
  #         /\/testimonials\//i,
  #         /\/list-your-business\//i,
  #         /\/faq\//i,
  #         /\/contact\//i,
  #         /\/tips-advice\//i,
  #         /\/photo-galleries\//i
  #   ],
  #   :black_lists => [
  #         /\/#/,
  #         /\/quote\//,
  #         /\/directory\//,
  #         /\/article\//,          
  #         /secure\.omg\.com\.au/i,
  #         /secure_omg/i
  #   ]
  # }

  :lawyers => {
    :domain => "http://www.lawyers.com.au",
    :white_lists => [
          /\/legal-articles\//i,
          /\/about\//i,
          /\/list-your-law-firm\//i,
          /\/about\//i          
    ],
    :black_lists => [
          /\/#/,
          /\/quote\//i,
          /\/find-a-lawyer\//i,
          /\/article\//i,          
          /secure\.omg\.com\.au/i,
          /secure_omg/i
    ]
  }
}


domains.each do |key,domain_object|
  puts "Crawling... #{domain_object[:domain]}"

  sitemap = Crawler.new(domain_object[:domain], {
              :white_lists => domain_object[:white_lists],
              :black_lists => domain_object[:black_lists],
              :name => key
            })
end  