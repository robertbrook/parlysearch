require 'rubygems'
require 'spider'
require 'morph'
require 'hpricot'
require 'uri'

class ParlySpider
  class << self
    def spider start='http://www.parliament.uk/'
      begin
        do_spider start
      rescue Exception => e
        puts e.class.name
        puts e.to_s
        puts e.backtrace.join("\n")
      end
      @pages
    end

    private

    def do_spider start
      @pages = []
      @count = 0
      Spider.start_at(start) do |s|
        s.add_url_check { |url| parse_url?(url) }
        s.setup { |url| setup(url, s) }
        s.on(:failure) { |url, response, prior_url| log_failure(url, prior_url) }
        s.on(:success) { |url, response, prior_url| handle_resource(url, response, prior_url) }
        s.on(:every) { |url, response, prior_url|  }
      end
    end

    def parse_url? url
      add = (url =~ %r{^http://([^\.]+\.)+parliament\.uk.*}) && !url[/(pdf|css)$/] && !url[/(#[^\/]+)$/]
      if url.include?('scottish.parliament') ||
        url == 'http://www.publications.parliament.uk/pa/cm/cmparty/register/memi01.htm'
        # url == 'http://www.publications.parliament.uk/pa/jt199899/jtselect/jtpriv/43/8021002.htm' ||
        # url == 'http://www.publications.parliament.uk/pa/cm199798/cmselect/cmagric/753/80519a02.htm' ||
        # url == 'http://www.publications.parliament.uk/pa/cm199798/cmselect/cmenvtra/844/8062325.htm' ||
        # url == 'http://www.publications.parliament.uk/pa/cm199798/cmselect/cmenvtra/495/495171.htm' ||
        # url == 'http://www.publications.parliament.uk/pa/cm199798/cmselect/cmenvtra/495/495144.htm' ||
        # url == 'http://www.publications.parliament.uk/pa/cm199798/cmselect/cmenvtra/495/495110.htm' ||
        # url == 'http://www.publications.parliament.uk/pa/cm199798/cmselect/cmenvtra/495/495107.htm' ||
        # url == 'http://www.publications.parliament.uk/pa/jt200203/jtselect/jtrights/188/188we18.htm'
        add = false
      end
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

      puts "***************************************"
      puts "#{@count} #{url}"

      if @count > 10000
        raise 'end'
      elsif url.include?('www.facebook.com')
        # ignore
      elsif ParlyResource.exists?(:url => url)
        resource = ParlyResource.find_by_url(url)
        load_uri(response, url, resource) if resource.date
      else
        load_uri response, url
      end
      puts "======================================="
    end

    def out_of_date existing, attributes
      existing && (existing.date && attributes[:date] && existing.date < attributes[:date])
    end

    def load_uri response, url, existing=nil
      begin
        attributes = load_data(response, url, existing)

        if !existing
          puts 'saving ' + url
          ParlyResource.create!(attributes)
          @count += 1
        elsif out_of_date(existing, attributes)
          puts 'updating ' + url
          existing.update_attributes!(attributes)
          @count += 1
        end

      rescue Exception => e
        puts e.class.name
        puts e.to_s
        puts e.backtrace.join("\n")
      end
    end

    def load_data response, url, existing
      puts "#{response.code}: #{url}"
      data = ResourceData.new
      data.url = url
      data.body = response.body
      doc = Hpricot data.body

      add_page_title(doc, data)
      add_response_header_attributes(response, data)
      add_html_meta_attributes(doc, data)
      parse_time_attributes(data)

      attributes = data.morph_attributes
      delete_uneeded_attributes(attributes)
      collapse_array_attribute_values(attributes)

      attributes
    end

    def add_html_meta_attributes doc, data
      meta = (doc/'/html/head/meta')
      meta_attributes = meta.each do |m|
        name = m['name']
        content = m['content'].to_s
        if name && !content.blank? && !name[/^(title)$/i]
          if data.respond_to?(name.downcase.to_sym) && (value = data.send(name.downcase.to_sym))
            value = [value] unless value.is_a?(Array)
            value << content
            data.morph(name, value)
          else
            data.morph(name, content)
          end
        end
      end
    end

    def add_response_header_attributes response, data
      response.header.each { |key, value| data.morph(key, value) }

      if data.date
        data.response_date = data.date
        data.date = nil
      end
    end

    def add_page_title doc, data
      data.title = doc.at('/html/head/title/text()').to_s

      if data.title.nil?
        raise "No title found, indexing aborted"
      elsif data.title == "Broadband Link - Error"
        raise "Router caching error, indexing aborted"
      end
    end

    def parse_time_attributes data
      begin
        data.date = Time.parse(data.date) if data.date
      rescue Exception => e
        puts "cannot parse date: #{data.date}"
        puts e.class.name
        puts e.to_s
        puts e.backtrace.join("\n")
      end
      data.response_date = Time.parse(data.response_date) if data.response_date
      data.last_modified = Time.parse(data.last_modified) if data.respond_to?(:last_modified) && data.last_modified
      data.coverage = Time.parse(data.coverage) if data.respond_to?(:coverage) && data.coverage
    end

    def delete_uneeded_attributes attributes
      [:connection, :x_aspnetmvc_version, :x_aspnet_version,
      :viewport, :version, :originator, :generator, :x_pingback, :pingback,
      :content_location, :progid, :otheragent, :form, :robots,
      :columns, :vs_targetschema, :vs_defaultclientscript, :code_language].each do |x|
        attributes.delete(x)
      end
    end

    def collapse_array_attribute_values attributes
      attributes.each do |key, value|
        if value.is_a?(Array)
          attributes[key] = value.inspect
        end
      end
    end

  end

end

class ResourceData
  include Morph
end
