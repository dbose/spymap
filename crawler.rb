#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'
require 'builder'
require 'pry'
 
class Crawler
 
  EXTENSIONS_IGNORED = %w[.csv .doc .docx .gif .jpg .jpeg .js .mp3 
    .mp4 .mpg .mpeg .pdf .png .ppt .rss .swf .txt .xls .xlsx .xml]
 
  PROTOCOLS_IGNORED = %w[feed ftp itms javascript mailto]

  def initialize(starting_url, options = {})

    options = {
      :white_lists => [],
      :black_lists => [],
      :quiet_mode => false,
      :debug  => true
    }.merge(options);

    @bad_pages = []  
    @agent = ::Mechanize.new
    @debug = options[:debug]
    @visited_pages = []
    @quiet_mode = options[:quiet_mode]
    @starting_url = starting_url    
    @white_lists = options[:white_lists]
    @black_lists = options[:black_lists]
    @starting_url_domain = starting_url[/([a-z0-9-]+)\.([a-z.]+)/i]
    @name = options[:name]

    puts "domain: #{@starting_url_domain}" if @debug
    
    extract_and_call_urls(starting_url)
    generate_sitemap 
  end
 
  def extract_and_call_urls(url)            
    #get page
    puts "#{@visited_pages.size+1} #{url}" unless @quiet_mode
    begin
      page = @agent.get(url)
    rescue => exception
      @bad_pages << url
      puts "error: #{url}, #{exception.message}"
      return
    end
 
    #for any content types we may have missed above, exit if content type is not html
    return if page.instance_of?(Mechanize::File) || 
              page.instance_of?(Mechanize::XmlFile) || 
              page.instance_of?(Mechanize::Image) || 
              (page.content_type.index('text/html') == nil)
 
    #add to array
    @visited_pages << url
 
    #get links found on page
    links = page.links
 
    #for each link, call the url if not in history
    links.each do |link| 
      link.uri rescue next
      next if link.uri.nil?      
      child_url = page.uri.merge(link.uri).to_s

      # Check black lists first
      next if @visited_pages.include?(child_url) || ignore_url?(child_url)

      # Check for white-lists
      if list_include?(@white_lists, child_url)
        extract_and_call_urls(child_url)
      end         

    end

  end
 
  private

  def list_include?(list, url)
    return true if list.empty?
    list.find {|pattern| pattern =~ url }
  end  
 
  def ignore_url?(url)
    begin
      return ignored = true if url.nil? ||                       
                              list_include?(@black_lists, url) || 
                              @bad_pages.include?(url) ||
                              PROTOCOLS_IGNORED.find{ |prt| url =~ /#{prt}:/ } != nil ||
                              EXTENSIONS_IGNORED.find{ |ext| url =~ /#{ext}$/ } != nil
    ensure
      puts "ignored: #{url}" if ignored and @debug
    end
  end
 
  def generate_sitemap
  	xml_str = ""
  	xml = Builder::XmlMarkup.new(:target => xml_str, :indent=>2)
 
  	xml.instruct!
  	xml.urlset(:xmlns=>'http://www.sitemaps.org/schemas/sitemap/0.9') {
  		@visited_pages.uniq.each do |url|  		  
  	    xml.url {
    	    xml.loc(url)
    			xml.lastmod(Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00"))
    			xml.changefreq('weekly')
 			  }   			
  		end
  	}
 
  	save_file(xml_str)  	
  end
 
	# Saves the xml file to disc. This could also be used to ping the webmaster tools
	def save_file(xml)
		File.open("#{@name}-sitemap.xml", "w+") do |f|
			f.write(xml)	
		end		
	end
 	
end

# if ARGV.empty?
#   puts "Usage: ./crawler.rb http://www.foo.com"
# end  

# sitemap = Crawler.new(ARGV[0])