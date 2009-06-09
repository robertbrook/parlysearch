# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090609142033) do

  create_table "parly_resources", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.text     "body"
    t.string   "accept_ranges"
    t.string   "cache_control"
    t.string   "content_length"
    t.string   "content_type"
    t.datetime "date"
    t.string   "etag"
    t.string   "expires"
    t.datetime "last_modified"
    t.string   "pragma"
    t.string   "server"
    t.string   "set_cookie"
    t.string   "transfer_encoding"
    t.string   "url"
    t.string   "x_powered_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pagesubject"
    t.string   "sitesectiontype"
    t.string   "subsectiontype"
    t.string   "keywords"
    t.string   "subject"
    t.string   "publisher"
    t.string   "author"
    t.string   "objecttype"
    t.string   "identifier"
    t.string   "source"
    t.string   "place"
    t.string   "isbn"
    t.string   "report"
  end

  add_index "parly_resources", ["url"], :name => "index_parly_resources_on_url"

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope",          :limit => 40
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "scope", "sequence"], :name => "index_slugs_on_name_and_sluggable_type_and_scope_and_sequence", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

end
