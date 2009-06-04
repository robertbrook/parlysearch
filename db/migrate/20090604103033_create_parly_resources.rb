class CreateParlyResources < ActiveRecord::Migration
  def self.up
    create_table :parly_resources, :force => true do |t|
      t.string :title
      t.text :description
      t.text :body
      t.string :accept_ranges
      t.string :cache_control
      t.string :content_length
      t.string :content_type
      t.datetime :date
      t.string :etag
      t.string :expires
      t.datetime :last_modified
      t.string :pragma
      t.string :server
      t.string :set_cookie
      t.string :transfer_encoding
      t.string :url
      t.string :x_powered_by

      t.timestamps
    end

    add_index :parly_resources, :url
  end

  def self.down
    drop_table :parly_resources
  end
end
