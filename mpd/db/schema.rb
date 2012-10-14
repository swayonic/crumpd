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

ActiveRecord::Schema.define(:version => 10) do

  create_table "assignments", :force => true do |t|
    t.integer "user_id"
    t.integer "team_id"
    t.integer "group_id"
    t.decimal "monthly_goal", :precision => 10, :scale => 0
    t.decimal "onetime_goal", :precision => 10, :scale => 0
  end

  add_index "assignments", ["group_id"], :name => "fk_assignments_groups"
  add_index "assignments", ["team_id"], :name => "fk_assignments_teams"
  add_index "assignments", ["user_id"], :name => "fk_assignments_users"

  create_table "group_coaches", :force => true do |t|
    t.integer "user_id"
    t.integer "group_id"
  end

  add_index "group_coaches", ["group_id"], :name => "fk_coaches_groups"
  add_index "group_coaches", ["user_id"], :name => "fk_coaches_users"

  create_table "groups", :force => true do |t|
    t.string  "name"
    t.integer "period_id"
  end

  add_index "groups", ["period_id"], :name => "fk_groups_periods"

  create_table "period_admins", :force => true do |t|
    t.integer "user_id"
    t.integer "period_id"
  end

  add_index "period_admins", ["period_id"], :name => "fk_admins_periods"
  add_index "period_admins", ["user_id"], :name => "fk_admins_users"

  create_table "periods", :force => true do |t|
    t.string "name",  :null => false
    t.date   "start"
    t.date   "end"
  end

  create_table "pledges", :force => true do |t|
    t.integer "assignment_id"
    t.string  "name"
    t.decimal "amount",        :precision => 10, :scale => 0
    t.decimal "frequency",     :precision => 10, :scale => 0
    t.boolean "is_in_hand",                                   :default => false, :null => false
  end

  add_index "pledges", ["assignment_id"], :name => "fk_pledges_assignments"

  create_table "reports", :force => true do |t|
    t.integer  "assignment_id"
    t.decimal  "monthly_inhand",      :precision => 10, :scale => 0
    t.decimal  "new_monthly_amt",     :precision => 10, :scale => 0
    t.integer  "new_monthly_count"
    t.decimal  "new_monthly_pledged", :precision => 10, :scale => 0
    t.decimal  "onetime_inhand",      :precision => 10, :scale => 0
    t.decimal  "new_onetime_amt",     :precision => 10, :scale => 0
    t.integer  "new_onetime_count"
    t.decimal  "onetime_pledged",     :precision => 10, :scale => 0
    t.decimal  "account_balance",     :precision => 10, :scale => 0
    t.integer  "num_contacts"
    t.integer  "new_referrals"
    t.integer  "num_phone_dials"
    t.integer  "num_phone_convos"
    t.float    "phone_hours"
    t.integer  "num_precall_letters"
    t.integer  "num_support_letters"
    t.float    "letter_hours"
    t.float    "mpd_hours"
    t.boolean  "had_coach_convo"
    t.text     "prayer_requests"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
  end

  add_index "reports", ["assignment_id"], :name => "fk_reports_assignments"

  create_table "team_leaders", :force => true do |t|
    t.integer "user_id"
    t.integer "team_id"
  end

  add_index "team_leaders", ["team_id"], :name => "fk_leaders_teams"
  add_index "team_leaders", ["user_id"], :name => "fk_leaders_users"

  create_table "teams", :force => true do |t|
    t.string  "name",      :null => false
    t.integer "period_id"
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
