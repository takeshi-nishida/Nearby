# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120925120754) do

  create_table "events", :force => true do |t|
    t.string   "description"
    t.string   "style"
    t.integer  "size1"
    t.integer  "number1"
    t.integer  "size2"
    t.integer  "number2"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "seatings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "table_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "seatings", ["table_id"], :name => "index_seatings_on_table_id"
  add_index "seatings", ["user_id"], :name => "index_seatings_on_user_id"

  create_table "tables", :force => true do |t|
    t.integer  "event_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "tables", ["event_id"], :name => "index_tables_on_event_id"

  create_table "topics", :force => true do |t|
    t.integer  "user_id"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "password_digest"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "affiliation"
    t.string   "furigana"
    t.boolean  "exclude",         :default => false
  end

  create_table "wants", :force => true do |t|
    t.integer  "user_id"
    t.integer  "who_id"
    t.integer  "wantable_id"
    t.string   "wantable_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "wants", ["user_id"], :name => "index_wants_on_user_id"
  add_index "wants", ["wantable_id"], :name => "index_wants_on_wantable_id"
  add_index "wants", ["who_id"], :name => "index_wants_on_who_id"

end
