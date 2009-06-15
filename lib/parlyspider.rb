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
      rescue
        # ignore
      end
      @pages
    end
  end

  private

    def self.do_spider start
      @pages = []
      @count = 0
      Spider.start_at(start) do |s|
        s.add_url_check do |a_url|
          add = (a_url =~ %r{^http://([^\.]+\.)+parliament\.uk.*}) && !a_url[/(pdf|css)$/] && !a_url[/(#[^\/]+)$/]
          if a_url.include?('scottish.parliament') ||
            a_url == 'http://www.publications.parliament.uk/pa/cm/cmparty/register/memi01.htm'
            # a_url == 'http://www.publications.parliament.uk/pa/jt199899/jtselect/jtpriv/43/8021002.htm' ||
            # a_url == 'http://www.publications.parliament.uk/pa/cm199798/cmselect/cmagric/753/80519a02.htm' ||
            # a_url == 'http://www.publications.parliament.uk/pa/cm199798/cmselect/cmenvtra/844/8062325.htm' ||
            # a_url == 'http://www.publications.parliament.uk/pa/cm199798/cmselect/cmenvtra/495/495171.htm' ||
            # a_url == 'http://www.publications.parliament.uk/pa/cm199798/cmselect/cmenvtra/495/495144.htm' ||
            # a_url == 'http://www.publications.parliament.uk/pa/cm199798/cmselect/cmenvtra/495/495110.htm' ||
            # a_url == 'http://www.publications.parliament.uk/pa/cm199798/cmselect/cmenvtra/495/495107.htm' ||
            # a_url == 'http://www.publications.parliament.uk/pa/jt200203/jtselect/jtrights/188/188we18.htm'
            add = false
          end
          add
        end

        s.setup do |a_url|
          # if a_url =~ %r{^http://.*wikipedia.*}
            # s.headers['If-Modified-Since'] = 'Wed, 29 Apr 2009 08:14:31 GMT'
          # end
        end

        s.on :failure do |a_url, response, prior_url|
          puts "URL failed: #{a_url}"
          puts " linked from #{prior_url}"
        end

        s.on :success do |a_url, response, prior_url|
          puts "***************************************"

          a_url.gsub!(/\/[^\/]+\/\.\.\//, '/') while a_url.include? '/../'
          u = URI.parse(a_url)
          a_url = u.to_s.split(u.path).first + u.path

          puts "#{@count} #{a_url}"

          if @count > 10000
            raise 'end'
          elsif a_url.include?('www.facebook.com')
            # ignore
          elsif ParlyResource.exists?(:url => a_url)
            resource = ParlyResource.find_by_url(a_url)
            if resource.date
              load_uri response, a_url, resource
            end
          else
            load_uri response, a_url
          end
          puts "======================================="
        end

        s.on :every do |a_url, response, prior_url|
        end
      end
    end

    def self.load_uri response, a_url, existing=nil
      begin
        puts "#{response.code}: #{a_url}"
        data = Page.new
        data.url = a_url
        data.body = response.body
        doc = Hpricot data.body
        data.title = doc.at('/html/head/title/text()').to_s

        response.header.each do |k,v|
          data.morph(k,v)
        end
        if data.date
          data.response_date = data.date
          data.date = nil
        end

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
        attributes = data.morph_attributes
        attributes.each do |key, value|
          if value.is_a?(Array)
            attributes[key] = value.inspect
          end
        end
        [:connection, :x_aspnetmvc_version, :x_aspnet_version,
        :viewport, :version, :originator, :generator, :x_pingback, :pingback,
        :content_location, :progid, :otheragent, :form, :robots,
        :columns, :vs_targetschema, :vs_defaultclientscript, :code_language].each do |x|
          attributes.delete(x)
        end

        begin
          if existing
            out_of_date = (existing.date && data.date && existing.date < data.date)
            unless out_of_date
              out_of_date = data.language && !existing.language?
            end
            if out_of_date
              puts 'updating ' + a_url
              resource = existing.update_attributes! attributes
              resource = existing
              @count += 1
            end
          else
            puts 'saving ' + a_url
            resource = ParlyResource.create! attributes
            @count += 1
          end
        rescue Exception => e
          puts e.class.name
          puts e.to_s
          puts e.backtrace.join("\n")
        end

      rescue Exception => e
        puts e.class.name
        puts e.to_s
        puts e.backtrace.join("\n")
        raise e
      end
    end
end

class Page
  include Morph
end
