class AddPagetypeToParlyResources < ActiveRecord::Migration
  def self.up
    add_column :parly_resources, :pagetype, :string
  end

  def self.down
    remove_column :parly_resources, :pagetype
  end
end
