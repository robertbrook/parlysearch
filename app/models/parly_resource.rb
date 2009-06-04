class ParlyResource < ActiveRecord::Base

  acts_as_solr :fields => [:title, :description, :body]

  def short_title
    title.sub('UK Parliament - ','')
  end

  def unique_description
    short_title != description ? description : ''
  end
end
