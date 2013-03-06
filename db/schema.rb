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

ActiveRecord::Schema.define(:version => 20121118082645) do

  create_table "accounts", :force => true do |t|
    t.string   "phone_number"
    t.string   "account_name"
    t.string   "name"
    t.string   "location"
    t.string   "password"
    t.boolean  "admin",        :default => false
    t.string   "email"
    t.boolean  "verified",     :default => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "problems", :force => true do |t|
    t.string   "location"
    t.string   "skills"
    t.string   "summary"
    t.text     "description"
    t.float    "wage"
    t.integer  "account_id"
    t.boolean  "archived",    :default => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "skill_verifications", :force => true do |t|
    t.integer  "account_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "skills", :force => true do |t|
    t.string   "skill_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
