require 'htmlentities'

class ParlyResource < ActiveRecord::Base

  extend ActionView::Helpers::SanitizeHelper::ClassMethods
  include ActionView::Helpers::SanitizeHelper

  acts_as_solr :fields => [:short_title, :description, :text]

  class << self
    def search term, offset, limit
      solr_results = find_by_solr(term, :offset => offset, :limit => limit)
      return [solr_results.results, solr_results.total]
    end
  end

  def short_title
    title.sub('UK Parliament - ','').sub('www.parliament.uk | ','').sub('www.parliament.uk |','')
  end

  def unique_description
    (description && short_title != description) ? description : ''
  end

  def text
    return nil unless body
    text = strip_tags(body)
    HTMLEntities.new.decode(text)
  end

  def file_format
    if content_type.include?('text/html')
      return 'HTML'
    elsif content_type.include?('PDF')
      return 'PDF / Adobe Acrobat'
    else
      return content_type
    end
  end
end
