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

ActiveRecord::Schema.define(:version => 20130410113043) do

  create_table "assignments", :force => true do |t|
    t.integer "user_id",     :null => false
    t.integer "period_id",   :null => false
    t.integer "team_id"
    t.integer "group_id"
    t.string  "intern_type"
    t.string  "status"
  end

  create_table "bmarks", :force => true do |t|
    t.integer  "period_id",                   :null => false
    t.datetime "date",                        :null => false
    t.integer  "percentage", :default => 100, :null => false
  end

  create_table "goals", :force => true do |t|
    t.integer "assignment_id", :null => false
    t.integer "frequency",     :null => false
    t.decimal "amount",        :null => false
  end

  create_table "group_coaches", :force => true do |t|
    t.integer "user_id",  :null => false
    t.integer "group_id", :null => false
  end

  create_table "groups", :force => true do |t|
    t.integer "period_id",  :null => false
    t.string  "name"
    t.string  "coach_name"
  end

  create_table "period_admins", :force => true do |t|
    t.integer "user_id",   :null => false
    t.integer "period_id", :null => false
  end

  create_table "periods", :force => true do |t|
    t.integer  "region_id",                      :null => false
    t.integer  "year",                           :null => false
    t.boolean  "keep_updated", :default => true, :null => false
    t.datetime "last_updated"
  end

  create_table "pledges", :force => true do |t|
    t.integer "assignment_id",                    :null => false
    t.string  "name",                             :null => false
    t.decimal "amount",                           :null => false
    t.integer "frequency",                        :null => false
    t.boolean "is_in_hand",    :default => false, :null => false
  end

  create_table "regions", :force => true do |t|
    t.string "name",      :null => false
    t.string "title"
    t.string "time_zone"
  end

  create_table "report_field_lines", :force => true do |t|
    t.integer "report_id",       :null => false
    t.integer "report_field_id", :null => false
    t.string  "value"
  end

  create_table "report_fields", :force => true do |t|
    t.integer "period_id",                      :null => false
    t.integer "list_index",  :default => 1,     :null => false
    t.string  "name",                           :null => false
    t.string  "field_type",  :default => "I",   :null => false
    t.boolean "required",    :default => false, :null => false
    t.string  "description"
    t.boolean "active",      :default => true,  :null => false
  end

  create_table "report_goal_lines", :force => true do |t|
    t.integer "report_id",                  :null => false
    t.integer "frequency",                  :null => false
    t.decimal "inhand",    :default => 0.0
    t.decimal "pledged",   :default => 0.0
  end

  create_table "reports", :force => true do |t|
    t.integer  "assignment_id", :null => false
    t.datetime "date"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "updated_by"
  end

  create_table "team_leaders", :force => true do |t|
    t.integer "user_id", :null => false
    t.integer "team_id", :null => false
  end

  create_table "teams", :force => true do |t|
    t.integer "period_id",    :null => false
    t.string  "name"
    t.integer "sitrack_id"
    t.string  "city"
    t.string  "state"
    t.string  "country"
    t.string  "continent"
    t.string  "sitrack_name"
  end

  create_table "users", :force => true do |t|
    t.string  "guid"
    t.string  "account_number"
    t.string  "first_name"
    t.string  "last_name"
    t.string  "preferred_name"
    t.string  "phone"
    t.string  "email"
    t.boolean "is_admin",       :default => false, :null => false
    t.string  "time_zone"
  end

end
