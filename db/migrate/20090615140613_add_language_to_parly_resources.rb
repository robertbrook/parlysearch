class AddLanguageToParlyResources < ActiveRecord::Migration
  def self.up
    add_column :parly_resources, :language, :string
  end

  def self.down
    remove_column :parly_resources, :language
  end
end
