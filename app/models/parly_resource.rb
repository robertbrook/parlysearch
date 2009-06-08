require 'htmlentities'

class ParlyResource < ActiveRecord::Base

  extend ActionView::Helpers::SanitizeHelper::ClassMethods
  include ActionView::Helpers::SanitizeHelper

  acts_as_solr :fields => [:short_title, :description, :text]

  def short_title
    title.sub('UK Parliament - ','').sub('www.parliament.uk | ','').sub('www.parliament.uk |','')
  end

  def unique_description
    short_title != description ? description : ''
  end

  def text
    return nil unless body
    text = strip_tags(body)
    HTMLEntities.new.decode(text)
  end
end
