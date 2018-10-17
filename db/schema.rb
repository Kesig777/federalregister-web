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

ActiveRecord::Schema.define(:version => 20180920170239) do

  create_table "clippings", :force => true do |t|
    t.integer  "user_id"
    t.string   "document_number"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "folder_id"
  end

  create_table "comment_attachments", :force => true do |t|
    t.string   "token"
    t.string   "attachment"
    t.string   "attachment_md5"
    t.string   "salt"
    t.string   "iv"
    t.integer  "file_size"
    t.string   "content_type"
    t.string   "original_file_name"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "comment_attachments", ["created_at"], :name => "index_comment_attachments_on_created_at"

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.string   "document_number"
    t.string   "comment_tracking_number"
    t.datetime "created_at"
    t.boolean  "comment_publication_notification"
    t.datetime "checked_comment_publication_at"
    t.string   "salt"
    t.string   "iv"
    t.binary   "encrypted_comment_data"
    t.string   "agency_name"
    t.boolean  "agency_participating"
    t.string   "comment_document_number"
    t.string   "submission_key"
  end

  add_index "comments", ["agency_participating"], :name => "index_comments_on_agency_participating"
  add_index "comments", ["comment_publication_notification"], :name => "index_comments_on_comment_publication_notification"
  add_index "comments", ["comment_tracking_number"], :name => "index_comments_on_comment_tracking_number"
  add_index "comments", ["document_number"], :name => "index_comments_on_document_number"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "entry_emails", :force => true do |t|
    t.string   "remote_ip"
    t.integer  "num_recipients"
    t.integer  "entry_id"
    t.string   "sender_hash"
    t.string   "document_number"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "folders", :force => true do |t|
    t.string   "name"
    t.string   "slug"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mailing_lists", :force => true do |t|
    t.text     "parameters"
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "type"
    t.datetime "deleted_at"
  end

  add_index "mailing_lists", ["deleted_at"], :name => "index_mailing_lists_on_deleted_at"

  create_table "subscriptions", :force => true do |t|
    t.integer  "mailing_list_id"
    t.string   "requesting_ip"
    t.string   "token"
    t.datetime "unsubscribed_at"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.datetime "last_delivered_at"
    t.integer  "delivery_count"
    t.date     "last_issue_delivered"
    t.string   "environment"
    t.integer  "user_id"
    t.integer  "comment_id"
    t.datetime "deleted_at"
    t.string   "last_documents_delivered_hash"
  end

  add_index "subscriptions", ["comment_id"], :name => "index_subscriptions_on_comment_id"
  add_index "subscriptions", ["deleted_at"], :name => "index_subscriptions_on_deleted_at"
  add_index "subscriptions", ["mailing_list_id", "deleted_at"], :name => "index_subscriptions_on_mailing_list_id_and_deleted_at"
  add_index "subscriptions", ["mailing_list_id", "last_documents_delivered_hash"], :name => "mailing_list_documents"

  create_table "users", :force => true do |t|
    t.string   "email",                  :limit => 120, :default => ""
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token",   :limit => 20
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "new_clippings_count"
    t.string   "confirmation_token",     :limit => 20
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
