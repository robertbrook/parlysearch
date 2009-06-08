require 'lib/parlyspider.rb'

namespace :parlysearch do

  desc "Spider and index - in beta!"
  task :spider => :environment do
    begin
      system 'rake solr:stop' # ensure solr is stopped
    rescue Exception => e
      puts e.class.name
      puts e.to_s
    end
    begin
      system 'rake solr:start' # ensure solr is running
    rescue Exception => e
      puts e.class.name
      puts e.to_s
    end
    ParlySpider.spider
  end
end

