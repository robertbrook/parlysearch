class AddPdfAttributesToParlyResources < ActiveRecord::Migration
  def self.up
    add_column :parly_resources, :creator, :string
    add_column :parly_resources, :producer, :string
    add_column :parly_resources, :creationdate, :string
  end

  def self.down
    remove_column :parly_resources, :creator
    remove_column :parly_resources, :producer
    remove_column :parly_resources, :creationdate
  end
end
