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

ActiveRecord::Schema.define(:version => 20121205151540) do

  create_table "password_recoveries", :force => true do |t|
    t.integer  "user_id"
    t.string   "reset_link"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "password_recoveries", ["reset_link"], :name => "index_password_recoveries_on_reset_link", :unique => true
  add_index "password_recoveries", ["user_id"], :name => "index_password_recoveries_on_user_id", :unique => true

  create_table "summer_residents_bungalows", :force => true do |t|
    t.string   "name"
    t.string   "unit"
    t.decimal  "phone",      :precision => 10, :scale => 0
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "summer_residents_families", :force => true do |t|
    t.integer  "home_id"
    t.integer  "bungalow_id"
    t.integer  "father_id"
    t.integer  "mother_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "summer_residents_families", ["bungalow_id"], :name => "index_summer_residents_families_on_bungalow_id", :unique => true
  add_index "summer_residents_families", ["father_id"], :name => "index_summer_residents_families_on_father_id", :unique => true
  add_index "summer_residents_families", ["home_id"], :name => "index_summer_residents_families_on_home_id", :unique => true
  add_index "summer_residents_families", ["mother_id"], :name => "index_summer_residents_families_on_mother_id", :unique => true

  create_table "summer_residents_homes", :force => true do |t|
    t.string   "address"
    t.string   "apartment"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.decimal  "phone",      :precision => 10, :scale => 0
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "summer_residents_residents", :force => true do |t|
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.decimal  "cell",       :precision => 10, :scale => 0
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "summer_residents_residents", ["user_id"], :name => "index_summer_residents_residents_on_user_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.boolean  "admin"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

end
