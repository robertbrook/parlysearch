require 'rubygems'
# require 'spider'
require 'uri'
require 'resource_data'

class ParlySpider
  class << self
    def spider start='http://www.parliament.uk/', pattern=nil
      begin
        Dir.mkdir("#{RAILS_ROOT}/data/pdfs") unless File.exist?("#{RAILS_ROOT}/data/pdfs")
        Dir.mkdir("#{RAILS_ROOT}/data/word_docs") unless File.exist?("#{RAILS_ROOT}/data/word_docs")
        do_spider start, pattern
      rescue Exception => e
        puts e.class.name
        puts e.to_s
        puts e.backtrace.join("\n")
      end
    end

    private

    def do_spider start, match_pattern
      @count = 0
      @match_pattern = match_pattern
      @start_url = start
      begin
        start_do_spider @start_url
      rescue Exeception => e
        warn "#{e.class.name} #{e.to_s}"
        warn e.bactrace.join("\n")
        warn "continuing from #{@start_url}"
        start_do_spider @start_url
        raise
      end
    end

    def start_do_spider start_url
      Spider.start_at(start_url) do |s|
        s.add_url_check do |url|
          add = parse_url?(url)
          @start_url = url if add
          add
        end
        s.setup { |url| setup(url, s) }
        s.on(:failure) { |url, response, prior_url| log_failure(url, prior_url) }
        s.on(:success) { |url, response, prior_url| handle_resource(url, response, prior_url) }
        s.on(:every) { |url, response, prior_url|  }
      end
    end

    def parse_url? url
      add = (url =~ %r{^http://([^\.]+\.)+parliament\.uk.*}) && !url[/(css|ico)$/] && !url[/(#[^\/]+)$/]
      if url.include?('scottish.parliament') ||
        url == 'http://www.publications.parliament.uk/pa/cm/cmparty/register/memi01.htm' ||
        url[/^http:\/\/www.publications.parliament.uk\/pa\/cm\/cmparty\/register\/register.*/]
        add = false
      end

      if (ResourceData.is_pdf?(url) || ResourceData.is_word?(url)) && ParlyResource.exists?(:url => url)
        add = false
      end

      if @match_pattern && !url.include?(@match_pattern)
        add = false
      end

      # if url[/cm199/]
        # add = false
      # end

      add
    end

    def log_failure url, prior_url
      puts "URL failed: #{url}"
      puts " linked from #{prior_url}"
    end

    def setup url, s
      # if url =~ %r{^http://.*wikipedia.*}
        # s.headers['If-Modified-Since'] = 'Wed, 29 Apr 2009 08:14:31 GMT'
      # end
    end

    def make_uri_absolute_and_strip_anchors url
      url.gsub!(/\/[^\/]+\/\.\.\//, '/') while url.include? '/../'
      u = URI.parse(url)
      u.to_s.split(u.path).first + u.path
    end

    def handle_resource url, response, prior_url
      url = make_uri_absolute_and_strip_anchors(url)
      puts "======================================="
      puts "#{@count} #{url} [#{response.code}]"
      puts "#{@count.to_s.gsub(/./,' ')} prior: #{prior_url}"

      if url.include?('www.facebook.com')
        # ignore
      elsif ParlyResource.exists?(:url => url)
        resource = ParlyResource.find_by_url(url)
        load_data(response, url, resource) if resource.date
      else
        load_data(response, url)
      end
    end

    def load_data response, url, existing=nil
      data = nil
      begin
        data = ResourceData.create(url, response)
        puts data.title.to_s

        if !existing
          ParlyResource.create!(data.attributes)
          @count += 1
        elsif data.out_of_date? existing
          existing.update_attributes!(data.attributes)
          @count += 1
        end

      rescue Exception => e
        puts(data.class.name) if data
        y(data.attributes) if data
        puts e.class.name
        puts e.to_s
        puts e.backtrace.join("\n")
      end
    end
  end

end
