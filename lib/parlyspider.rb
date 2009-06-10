require 'rubygems'
require 'spider'
require 'morph'
require 'hpricot'

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
      count = 0
      Spider.start_at(start) do |s|
        s.add_url_check do |a_url|
          add = a_url =~ %r{^http://([^\.]+\.)+parliament\.uk.*} && !a_url[/(pdf|css)$/]
          if a_url.include?('scottish.parliament') ||
            a_url == 'http://www.publications.parliament.uk/pa/jt199899/jtselect/jtpriv/43/8040702.htm' ||
            a_url == 'http://www.publications.parliament.uk/pa/jt199899/jtselect/jtpriv/43/8021002.htm'
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
          puts "#{count} #{a_url}"

          a_url.gsub!(/\/[^\/]+\/\.\.\//, '/') while a_url.include? '/../'
          if count > 10000
            raise 'end'
          elsif !ParlyResource.exists?(:url => a_url) && !a_url.include?('www.facebook.com')
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

              data.date = Time.parse(data.date) if data.date
              data.response_date = Time.parse(data.response_date) if data.response_date
              data.last_modified = Time.parse(data.last_modified) if data.respond_to?(:last_modified) && data.last_modified
              data.coverage = Time.parse(data.coverage) if data.respond_to?(:coverage) && data.coverage
              attributes = data.morph_attributes
              attributes.each do |key, value|
                if value.is_a?(Array)
                  attributes[key] = value.inspect
                end
              end
              [:connection, :x_aspnetmvc_version, :x_aspnet_version, :language,
              :viewport, :version, :originator, :generator, :x_pingback, :pingback,
              :content_location, :progid, :otheragent, :form, :robots].each do |x|
                attributes.delete(x)
              end

              begin
                puts 'saving ' + a_url
                resource = ParlyResource.create! attributes
                count += 1
              rescue Exception => e
                puts e.class.name
                puts e.to_s
              end

            rescue Exception => e
              puts e.class.name
              puts e.to_s
              raise e
            end
          end
          puts "======================================="
        end

        s.on :every do |a_url, response, prior_url|
        end
      end
  end
end

class Page
  include Morph
end
