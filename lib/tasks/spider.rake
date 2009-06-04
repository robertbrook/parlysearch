require 'lib/parlyspider.rb'

namespace :parlysearch do

  desc "Spider and index - in beta!"
  task :spider => :environment do
    begin
      system 'rake solr:start' # ensure solr is running
    rescue
    end
    ParlySpider.spider
  end
end

