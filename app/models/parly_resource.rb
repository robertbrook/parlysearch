class ParlyResource < ActiveRecord::Base

  acts_as_solr :fields => [:title, :description, :body]

end
