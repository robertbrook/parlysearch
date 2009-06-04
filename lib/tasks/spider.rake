require 'lib/parlyspider.rb'

namespace :parlysearch do
  desc "Make slugs for a model."
  task :spider => :environment do
    begin
      system 'rake solr:start' # ensure solr is running
    rescue
    end
    ParlySpider.spider
  end
end

