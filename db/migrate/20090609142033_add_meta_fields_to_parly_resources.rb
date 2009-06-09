class AddMetaFieldsToParlyResources < ActiveRecord::Migration
  def self.up
    add_column :parly_resources, :pagesubject, :string
    add_column :parly_resources, :sitesectiontype, :string
    add_column :parly_resources, :subsectiontype, :string
    add_column :parly_resources, :keywords, :string
    add_column :parly_resources, :subject, :string
    add_column :parly_resources, :publisher, :string
    add_column :parly_resources, :author, :string
    add_column :parly_resources, :objecttype, :string
    add_column :parly_resources, :identifier, :string
    add_column :parly_resources, :source, :string
    add_column :parly_resources, :place, :string
    add_column :parly_resources, :isbn, :string
    add_column :parly_resources, :report, :string
  end

  def self.down
    remove_column :parly_resources, :pagesubject
    remove_column :parly_resources, :sitesectiontype
    remove_column :parly_resources, :subsectiontype
    remove_column :parly_resources, :keywords
    remove_column :parly_resources, :subject
    remove_column :parly_resources, :publisher
    remove_column :parly_resources, :author
    remove_column :parly_resources, :objecttype
    remove_column :parly_resources, :identifier
    remove_column :parly_resources, :source
    remove_column :parly_resources, :place
    remove_column :parly_resources, :isbn
    remove_column :parly_resources, :report
  end
end
