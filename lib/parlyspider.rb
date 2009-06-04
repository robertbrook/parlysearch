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
          add = a_url =~ %r{^http://www.parliament.uk.*} && !a_url.ends_with?('pdf')
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
          if count > 200
            raise 'end'
          elsif !ParlyResource.exists?(:url => a_url)
            puts "#{response.code}: #{a_url}"
            data = Page.new
            data.url = a_url
            data.body = response.body
            begin
              doc = Hpricot data.body
              data.title = doc.at('/html/head/title/text()').to_s
              data.description = doc.at('/html/head/meta[@name="description"]')['content'].to_s
            rescue
            end
            response.header.each do |k,v|
              data.morph(k,v)
            end

            begin
              data.date = Time.parse(data.date) if data.date
              data.last_modified = Time.parse(data.last_modified) if data.respond_to?(:last_modified) && data.last_modified
              attributes = data.morph_attributes
              attributes.delete(:connection)
              attributes.delete(:x_aspnetmvc_version)
              attributes.delete(:x_aspnet_version)

              puts 'saving ' + a_url
              resource = ParlyResource.create! attributes
              count += 1
            rescue Exception => e
              puts e.class.name
              puts e.to_s
            end

            @pages << resource
          end
        end

        s.on :every do |a_url, response, prior_url|
        end
      end
  end
end

class Page
  include Morph
end
