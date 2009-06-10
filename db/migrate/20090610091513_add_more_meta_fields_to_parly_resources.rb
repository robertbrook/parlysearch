class AddMoreMetaFieldsToParlyResources < ActiveRecord::Migration
  def self.up
    add_column :parly_resources, :response_date, :datetime
    add_column :parly_resources, :coverage, :datetime
  end

  def self.down
    remove_column :parly_resources, :response_date
    remove_column :parly_resources, :coverage
  end
end
