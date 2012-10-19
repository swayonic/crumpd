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

ActiveRecord::Schema.define(:version => 14) do

  create_table "assignments", :force => true do |t|
    t.integer "user_id",   :null => false
    t.integer "period_id", :null => false
    t.integer "team_id"
    t.integer "group_id"
  end

  add_index "assignments", ["group_id"], :name => "fk_assignments_groups"
  add_index "assignments", ["period_id"], :name => "fk_assignments_periods"
  add_index "assignments", ["team_id"], :name => "fk_assignments_teams"
  add_index "assignments", ["user_id"], :name => "fk_assignments_users"

  create_table "goals", :force => true do |t|
    t.integer "assignment_id",                                :null => false
    t.integer "frequency",                                    :null => false
    t.decimal "amount",        :precision => 10, :scale => 0, :null => false
  end

  add_index "goals", ["assignment_id"], :name => "fk_goals_assignments"

  create_table "group_coaches", :force => true do |t|
    t.integer "user_id",  :null => false
    t.integer "group_id", :null => false
  end

  add_index "group_coaches", ["group_id"], :name => "fk_coaches_groups"
  add_index "group_coaches", ["user_id"], :name => "fk_coaches_users"

  create_table "groups", :force => true do |t|
    t.string  "name"
    t.integer "period_id", :null => false
  end

  add_index "groups", ["period_id"], :name => "fk_groups_periods"

  create_table "period_admins", :force => true do |t|
    t.integer "user_id",   :null => false
    t.integer "period_id", :null => false
  end

  add_index "period_admins", ["period_id"], :name => "fk_admins_periods"
  add_index "period_admins", ["user_id"], :name => "fk_admins_users"

  create_table "periods", :force => true do |t|
    t.string "name",  :null => false
    t.date   "start"
    t.date   "end"
  end

  create_table "pledges", :force => true do |t|
    t.integer "assignment_id",                                                   :null => false
    t.string  "name",                                                            :null => false
    t.decimal "amount",        :precision => 10, :scale => 0,                    :null => false
    t.integer "frequency",                                                       :null => false
    t.boolean "is_in_hand",                                   :default => false, :null => false
  end

  add_index "pledges", ["assignment_id"], :name => "fk_pledges_assignments"

  create_table "report_field_lines", :force => true do |t|
    t.integer "report_id",       :null => false
    t.integer "report_field_id", :null => false
    t.string  "value"
  end

  add_index "report_field_lines", ["report_field_id"], :name => "fk_report_field_lines_report_fields"
  add_index "report_field_lines", ["report_id"], :name => "fk_report_field_lines_reports"

  create_table "report_fields", :force => true do |t|
    t.integer "period_id",                      :null => false
    t.integer "list_index",  :default => 1,     :null => false
    t.string  "name",                           :null => false
    t.string  "field_type",                     :null => false
    t.boolean "required",    :default => false, :null => false
    t.string  "description"
    t.boolean "active",      :default => true,  :null => false
  end

  add_index "report_fields", ["period_id"], :name => "fk_report_fields_periods"

  create_table "report_goal_lines", :force => true do |t|
    t.integer "report_id",                                               :null => false
    t.integer "frequency",                                               :null => false
    t.decimal "inhand",    :precision => 10, :scale => 0, :default => 0
    t.decimal "pledged",   :precision => 10, :scale => 0, :default => 0
  end

  add_index "report_goal_lines", ["report_id"], :name => "fk_report_goal_lines_reports"

  create_table "reports", :force => true do |t|
    t.integer  "assignment_id", :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "updated_by"
  end

  add_index "reports", ["assignment_id"], :name => "fk_reports_assignments"
  add_index "reports", ["updated_by"], :name => "fk_reports_users"

  create_table "team_leaders", :force => true do |t|
    t.integer "user_id", :null => false
    t.integer "team_id", :null => false
  end

  add_index "team_leaders", ["team_id"], :name => "fk_leaders_teams"
  add_index "team_leaders", ["user_id"], :name => "fk_leaders_users"

  create_table "teams", :force => true do |t|
    t.string  "name",      :null => false
    t.integer "period_id", :null => false
    t.date    "start"
    t.date    "end"
  end

  add_index "teams", ["period_id"], :name => "fk_teams_periods"

  create_table "users", :force => true do |t|
    t.string  "first_name",                        :null => false
    t.string  "last_name",                         :null => false
    t.string  "account_number"
    t.string  "email"
    t.string  "phone"
    t.boolean "is_admin",       :default => false, :null => false
  end

end
