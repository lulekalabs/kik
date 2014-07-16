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

ActiveRecord::Schema.define(:version => 20110426203532) do

  create_table "academic_titles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "academic_titles", ["name"], :name => "index_academic_titles_on_name", :unique => true

  create_table "accesses", :force => true do |t|
    t.integer  "requestor_id"
    t.integer  "requestee_id"
    t.integer  "accessible_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accesses", ["accessible_id"], :name => "index_accesses_on_accessible_id"
  add_index "accesses", ["requestee_id"], :name => "index_accesses_on_requestee_id"
  add_index "accesses", ["requestor_id"], :name => "index_accesses_on_requestor_id"

  create_table "addresses", :force => true do |t|
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.integer  "academic_title_id"
    t.string   "gender",            :limit => 1
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.text     "street"
    t.string   "street_number"
    t.string   "city"
    t.string   "postal_code"
    t.string   "province"
    t.string   "province_code",     :limit => 2
    t.string   "country"
    t.string   "country_code",      :limit => 2
    t.string   "company_name"
    t.text     "note"
    t.string   "phone"
    t.string   "mobile"
    t.string   "fax"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "email"
  end

  add_index "addresses", ["academic_title_id"], :name => "index_addresses_on_academic_title_id"
  add_index "addresses", ["addressable_id", "addressable_type"], :name => "fk_addresses_addressable"
  add_index "addresses", ["city"], :name => "index_addresses_on_city"
  add_index "addresses", ["company_name"], :name => "index_addresses_on_company_name"
  add_index "addresses", ["country"], :name => "index_addresses_on_country"
  add_index "addresses", ["country_code"], :name => "index_addresses_on_country_code"
  add_index "addresses", ["email"], :name => "index_addresses_on_email"
  add_index "addresses", ["fax"], :name => "index_addresses_on_fax"
  add_index "addresses", ["first_name"], :name => "index_addresses_on_first_name"
  add_index "addresses", ["gender"], :name => "index_addresses_on_gender"
  add_index "addresses", ["last_name"], :name => "index_addresses_on_last_name"
  add_index "addresses", ["middle_name"], :name => "index_addresses_on_middle_name"
  add_index "addresses", ["mobile"], :name => "index_addresses_on_mobile"
  add_index "addresses", ["phone"], :name => "index_addresses_on_phone"
  add_index "addresses", ["province"], :name => "index_addresses_on_state"
  add_index "addresses", ["province_code"], :name => "index_addresses_on_state_code"
  add_index "addresses", ["type"], :name => "index_addresses_on_type"

  create_table "admin_users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                   :default => "passive"
    t.datetime "deleted_at"
    t.string   "reset_code"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email"
  add_index "admin_users", ["login"], :name => "index_admin_users_on_login"
  add_index "admin_users", ["reset_code"], :name => "index_admin_users_on_reset_code"

  create_table "advocates_topics", :id => false, :force => true do |t|
    t.integer "advocate_id"
    t.integer "topic_id"
  end

  add_index "advocates_topics", ["advocate_id", "topic_id"], :name => "index_advocates_topics_on_advocate_id_and_topic_id"

  create_table "articles", :force => true do |t|
    t.integer  "person_id"
    t.text     "body"
    t.string   "title"
    t.string   "type"
    t.string   "status",                            :default => "created"
    t.datetime "published_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "blog",                              :default => false
    t.boolean  "press_release",                     :default => false
    t.boolean  "dictionary",                        :default => false
    t.boolean  "press_review",                      :default => false
    t.boolean  "law_article",                       :default => false
    t.boolean  "faq",                               :default => false
    t.string   "author_name"
    t.text     "summary"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "primary_attachment_file_name"
    t.string   "primary_attachment_content_type"
    t.integer  "primary_attachment_file_size"
    t.datetime "primary_attachment_updated_at"
    t.string   "secondary_attachment_file_name"
    t.string   "secondary_attachment_content_type"
    t.integer  "secondary_attachment_file_size"
    t.datetime "secondary_attachment_updated_at"
    t.string   "url"
    t.string   "primary_attachment_name"
    t.string   "secondary_attachment_name"
    t.boolean  "client_view",                       :default => false
    t.boolean  "advocate_view",                     :default => false
    t.boolean  "kik_view",                          :default => true
    t.boolean  "advofinder_view",                   :default => false
  end

  add_index "articles", ["advocate_view"], :name => "index_articles_on_advocate_view"
  add_index "articles", ["advofinder_view"], :name => "index_articles_on_advofinder_view"
  add_index "articles", ["author_name"], :name => "index_articles_on_author_name"
  add_index "articles", ["blog"], :name => "index_articles_on_blog"
  add_index "articles", ["client_view"], :name => "index_articles_on_client_view"
  add_index "articles", ["dictionary"], :name => "index_articles_on_dictionary"
  add_index "articles", ["faq"], :name => "index_articles_on_faq"
  add_index "articles", ["kik_view"], :name => "index_articles_on_kik_view"
  add_index "articles", ["law_article"], :name => "index_articles_on_article"
  add_index "articles", ["person_id"], :name => "index_articles_on_person_id"
  add_index "articles", ["press_release"], :name => "index_articles_on_press"
  add_index "articles", ["press_review"], :name => "index_articles_on_press_review"
  add_index "articles", ["status"], :name => "index_articles_on_status"
  add_index "articles", ["title"], :name => "index_articles_on_title"
  add_index "articles", ["type"], :name => "index_articles_on_type"

  create_table "articles_topics", :id => false, :force => true do |t|
    t.integer "article_id"
    t.integer "topic_id"
  end

  add_index "articles_topics", ["article_id", "topic_id"], :name => "index_articles_topics_on_article_id_and_topic_id"

  create_table "assets", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "person_id"
    t.integer  "assetable_id"
    t.string   "assetable_type"
    t.string   "url"
    t.string   "name"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "type"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assets", ["assetable_id", "assetable_type"], :name => "index_assets_on_assetable_id_and_assetable_type"
  add_index "assets", ["parent_id"], :name => "index_assets_on_parent_id"
  add_index "assets", ["person_id"], :name => "index_assets_on_person_id"

  create_table "bar_associations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cart_line_items", :force => true do |t|
    t.string   "item_number"
    t.string   "name"
    t.string   "description"
    t.integer  "quantity",                  :default => 1,       :null => false
    t.string   "unit",                      :default => "piece", :null => false
    t.integer  "pieces",                    :default => 0,       :null => false
    t.integer  "cents",                     :default => 0,       :null => false
    t.string   "currency",     :limit => 3, :default => "USD",   :null => false
    t.boolean  "taxable",                   :default => false,   :null => false
    t.integer  "product_id",                                     :null => false
    t.string   "product_type",                                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cart_line_items", ["description"], :name => "index_cart_line_items_on_description"
  add_index "cart_line_items", ["item_number"], :name => "index_cart_line_items_on_item_number"
  add_index "cart_line_items", ["name"], :name => "index_cart_line_items_on_name"
  add_index "cart_line_items", ["pieces"], :name => "index_cart_line_items_on_pieces"
  add_index "cart_line_items", ["product_id", "product_type"], :name => "index_cart_line_items_on_product_id_and_product_type"
  add_index "cart_line_items", ["quantity"], :name => "index_cart_line_items_on_quantity"
  add_index "cart_line_items", ["unit"], :name => "index_cart_line_items_on_unit"

  create_table "comments", :force => true do |t|
    t.text     "message"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",           :default => "created", :null => false
    t.string   "type"
    t.float    "grade"
  end

  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"
  add_index "comments", ["person_id"], :name => "index_comments_on_person_id"
  add_index "comments", ["status"], :name => "index_comments_on_status"
  add_index "comments", ["type"], :name => "index_comments_on_type"

  create_table "contact_transactions", :force => true do |t|
    t.integer  "person_id"
    t.integer  "amount",     :default => 0,     :null => false
    t.datetime "expires_at"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "invoice_id"
    t.boolean  "flat",       :default => false, :null => false
    t.integer  "order_id"
    t.datetime "cleared_at"
    t.boolean  "flex",       :default => false, :null => false
    t.datetime "start_at"
  end

  add_index "contact_transactions", ["cleared_at"], :name => "index_contact_transactions_on_cleared_at"
  add_index "contact_transactions", ["flat"], :name => "index_contact_transactions_on_flat"
  add_index "contact_transactions", ["invoice_id"], :name => "index_contact_transactions_on_invoice_id"
  add_index "contact_transactions", ["order_id"], :name => "index_contact_transactions_on_order_id"
  add_index "contact_transactions", ["person_id"], :name => "index_contact_transactions_on_person_id"
  add_index "contact_transactions", ["start_at"], :name => "index_contact_transactions_on_start_at"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.boolean  "schedule",   :default => false
    t.integer  "period"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "enrollments", :force => true do |t|
    t.integer  "person_id"
    t.string   "gender",                  :limit => 1
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "type"
    t.string   "state",                                :default => "passive"
    t.string   "activation_code"
    t.datetime "activated_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "academic_title_id"
    t.boolean  "press_release_per_email",              :default => false
    t.boolean  "press_release_per_fax",                :default => false
    t.boolean  "press_release_per_mail",               :default => false
  end

  add_index "enrollments", ["activation_code"], :name => "index_enrollments_on_activation_code"
  add_index "enrollments", ["email"], :name => "index_enrollments_on_email"
  add_index "enrollments", ["person_id"], :name => "index_enrollments_on_person_id"
  add_index "enrollments", ["state"], :name => "index_enrollments_on_state"
  add_index "enrollments", ["type"], :name => "index_enrollments_on_type"

  create_table "follows", :force => true do |t|
    t.integer  "followable_id",                      :null => false
    t.string   "followable_type"
    t.integer  "follower_id",                        :null => false
    t.string   "follower_type"
    t.boolean  "blocked",         :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["followable_id", "followable_type"], :name => "index_follows_on_followable_id_and_followable_type"
  add_index "follows", ["follower_id", "follower_type"], :name => "index_follows_on_follower_id_and_follower_type"

  create_table "gateways", :force => true do |t|
    t.string "name",            :null => false
    t.string "mode"
    t.string "type"
    t.string "login_id"
    t.string "transaction_key"
  end

  add_index "gateways", ["name"], :name => "index_gateways_on_name"
  add_index "gateways", ["type"], :name => "index_gateways_on_type"

  create_table "invoices", :force => true do |t|
    t.integer  "buyer_id"
    t.string   "buyer_type"
    t.integer  "seller_id"
    t.string   "seller_type"
    t.integer  "net_cents",               :default => 0,         :null => false
    t.integer  "tax_cents",               :default => 0,         :null => false
    t.integer  "gross_cents",             :default => 0,         :null => false
    t.float    "tax_rate",                :default => 0.0,       :null => false
    t.string   "currency",                :default => "USD",     :null => false
    t.string   "type"
    t.string   "number"
    t.boolean  "lock_version",            :default => false,     :null => false
    t.string   "status",                  :default => "pending", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "paid_at"
    t.integer  "order_id"
    t.date     "service_period_start_on"
    t.date     "service_period_end_on"
    t.datetime "authorized_at"
    t.integer  "month_number"
    t.date     "billing_date_on"
  end

  add_index "invoices", ["billing_date_on"], :name => "index_invoices_on_billing_date_on"
  add_index "invoices", ["buyer_id", "buyer_type"], :name => "index_invoices_on_buyer_id_and_buyer_type"
  add_index "invoices", ["number"], :name => "index_invoices_on_number"
  add_index "invoices", ["order_id"], :name => "index_invoices_on_order_id"
  add_index "invoices", ["seller_id", "seller_type"], :name => "index_invoices_on_seller_id_and_seller_type"
  add_index "invoices", ["service_period_end_on"], :name => "index_invoices_on_service_period_end_on"
  add_index "invoices", ["service_period_start_on"], :name => "index_invoices_on_service_period_start_on"
  add_index "invoices", ["type"], :name => "index_invoices_on_type"

  create_table "kases", :force => true do |t|
    t.integer  "person_id"
    t.string   "type"
    t.string   "status",                          :default => "created"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "summary"
    t.string   "action_description"
    t.integer  "contract_period"
    t.float    "lat"
    t.float    "lng"
    t.string   "postal_code",        :limit => 5
    t.datetime "preapproved_at"
    t.datetime "opened_at"
    t.datetime "closed_at"
    t.string   "activation_code"
    t.datetime "expires_at"
    t.integer  "mandated_person_id"
    t.string   "mandated",                        :default => "0",       :null => false
    t.string   "close_reason"
    t.datetime "client_reminded_at"
    t.string   "province_code"
    t.string   "referrer"
  end

  add_index "kases", ["activation_code"], :name => "index_kases_on_activation_code"
  add_index "kases", ["closed_at"], :name => "index_kases_on_closed_at"
  add_index "kases", ["expires_at"], :name => "index_kases_on_expires_at"
  add_index "kases", ["mandated"], :name => "index_kases_on_mandated"
  add_index "kases", ["mandated_person_id"], :name => "index_kases_on_mandated_person_id"
  add_index "kases", ["opened_at"], :name => "index_kases_on_opened_at"
  add_index "kases", ["person_id"], :name => "index_kases_on_person_id"
  add_index "kases", ["postal_code"], :name => "index_kases_on_postal_code"
  add_index "kases", ["preapproved_at"], :name => "index_kases_on_preapproved_at"
  add_index "kases", ["province_code"], :name => "index_kases_on_province_code"
  add_index "kases", ["referrer"], :name => "index_kases_on_referrer"
  add_index "kases", ["status"], :name => "index_kases_on_status"
  add_index "kases", ["type"], :name => "index_kases_on_type"

  create_table "kases_topics", :id => false, :force => true do |t|
    t.integer "kase_id"
    t.integer "topic_id"
  end

  add_index "kases_topics", ["kase_id", "topic_id"], :name => "index_kases_topics_on_kase_id_and_topic_id"

  create_table "line_items", :force => true do |t|
    t.integer "order_id"
    t.integer "invoice_id"
    t.integer "sellable_id"
    t.string  "sellable_type"
    t.integer "net_cents"
    t.string  "currency"
    t.integer "tax_cents",     :default => 0,   :null => false
    t.integer "gross_cents",   :default => 0,   :null => false
    t.float   "tax_rate",      :default => 0.0, :null => false
  end

  add_index "line_items", ["invoice_id"], :name => "index_line_items_on_invoice_id"
  add_index "line_items", ["order_id"], :name => "index_line_items_on_order_id"
  add_index "line_items", ["sellable_id", "sellable_type"], :name => "fk_line_items_sellable"

  create_table "mandates", :force => true do |t|
    t.integer  "client_id"
    t.integer  "advocate_id"
    t.integer  "kase_id"
    t.integer  "response_id"
    t.string   "type"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",      :default => "created", :null => false
    t.datetime "accepted_at"
    t.datetime "declined_at"
  end

  add_index "mandates", ["advocate_id"], :name => "index_mandates_on_advocate_id"
  add_index "mandates", ["client_id"], :name => "index_mandates_on_client_id"
  add_index "mandates", ["kase_id"], :name => "index_mandates_on_kase_id"
  add_index "mandates", ["response_id"], :name => "index_mandates_on_response_id"
  add_index "mandates", ["status"], :name => "index_mandates_on_status"

  create_table "memorizes", :force => true do |t|
    t.integer  "person_id"
    t.integer  "advocate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.string   "type"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.string   "sender_first_name"
    t.string   "sender_last_name"
    t.string   "sender_email"
    t.string   "receiver_first_name"
    t.string   "receiver_last_name"
    t.string   "receiver_email"
    t.text     "message"
    t.string   "uuid"
    t.string   "status",                                   :default => "queued", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "sent_at"
    t.datetime "reminded_at"
    t.integer  "parent_id"
    t.string   "activation_code",            :limit => 40
    t.datetime "accepted_at"
    t.datetime "declined_at"
    t.datetime "deleted_at"
    t.string   "sender_gender",              :limit => 1
    t.string   "receiver_gender",            :limit => 1
    t.string   "subject"
    t.integer  "sender_academic_title_id"
    t.integer  "receiver_academic_title_id"
    t.string   "ip"
  end

  add_index "messages", ["activation_code"], :name => "index_messages_on_activation_code"
  add_index "messages", ["parent_id"], :name => "index_messages_on_parent_id"
  add_index "messages", ["receiver_email"], :name => "index_messages_on_receiver_email"
  add_index "messages", ["receiver_first_name"], :name => "index_messages_on_receiver_first_name"
  add_index "messages", ["receiver_id"], :name => "index_messages_on_receiver_id"
  add_index "messages", ["receiver_last_name"], :name => "index_messages_on_receiver_last_name"
  add_index "messages", ["reminded_at"], :name => "index_messages_on_reminded_at"
  add_index "messages", ["sender_email"], :name => "index_messages_on_sender_email"
  add_index "messages", ["sender_first_name"], :name => "index_messages_on_sender_first_name"
  add_index "messages", ["sender_id"], :name => "index_messages_on_sender_id"
  add_index "messages", ["sender_last_name"], :name => "index_messages_on_sender_last_name"
  add_index "messages", ["sent_at"], :name => "index_messages_on_sent_at"
  add_index "messages", ["status"], :name => "index_messages_on_status"
  add_index "messages", ["subject"], :name => "index_messages_on_subject"
  add_index "messages", ["type"], :name => "index_messages_on_type"
  add_index "messages", ["uuid"], :name => "index_messages_on_uuid"

  create_table "orders", :force => true do |t|
    t.integer  "buyer_id"
    t.string   "buyer_type"
    t.integer  "seller_id"
    t.string   "seller_type"
    t.integer  "invoice_id"
    t.integer  "net_cents",                                 :default => 0,         :null => false
    t.integer  "tax_cents",                                 :default => 0,         :null => false
    t.integer  "gross_cents",                               :default => 0,         :null => false
    t.string   "currency",                     :limit => 3, :default => "USD",     :null => false
    t.float    "tax_rate",                                  :default => 0.0,       :null => false
    t.string   "type"
    t.boolean  "lock_version",                              :default => false,     :null => false
    t.string   "status",                                    :default => "created", :null => false
    t.string   "number"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "canceled_at"
    t.string   "tax_number"
    t.string   "preferred_billing_method"
    t.date     "billing_due_on"
    t.boolean  "cancel_on_service_period_end",              :default => false,     :null => false
  end

  add_index "orders", ["billing_due_on"], :name => "index_orders_on_billing_due_on"
  add_index "orders", ["buyer_id", "buyer_type"], :name => "index_orders_on_buyer_id_and_buyer_type"
  add_index "orders", ["cancel_on_service_period_end"], :name => "index_orders_on_cancel_on_service_period_end"
  add_index "orders", ["seller_id", "seller_type"], :name => "index_orders_on_seller_id_and_seller_type"
  add_index "orders", ["status"], :name => "index_orders_on_status"
  add_index "orders", ["type"], :name => "index_orders_on_type"

  create_table "payments", :force => true do |t|
    t.integer  "payable_id"
    t.string   "payable_type"
    t.boolean  "success"
    t.string   "reference"
    t.string   "message"
    t.string   "action"
    t.string   "params"
    t.boolean  "test"
    t.integer  "cents",                                :default => 0,     :null => false
    t.string   "currency",                :limit => 3, :default => "USD", :null => false
    t.integer  "lock_version",                         :default => 0,     :null => false
    t.integer  "position"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bank_account_owner_name"
    t.string   "bank_account_number"
    t.string   "bank_routing_number"
    t.string   "bank_name"
    t.string   "bank_location"
    t.string   "paypal_account"
    t.string   "uuid"
    t.integer  "interval_length"
    t.string   "interval_unit"
    t.date     "duration_start_date"
    t.integer  "duration_occurrences"
  end

  add_index "payments", ["action"], :name => "index_payments_on_action"
  add_index "payments", ["message"], :name => "index_payments_on_message"
  add_index "payments", ["params"], :name => "index_payments_on_params"
  add_index "payments", ["payable_id", "payable_type"], :name => "index_payments_on_payable_id_and_payable_type"
  add_index "payments", ["position"], :name => "index_payments_on_position"
  add_index "payments", ["reference"], :name => "index_payments_on_reference"
  add_index "payments", ["uuid"], :name => "index_payments_on_uuid"

  create_table "people", :force => true do |t|
    t.string   "type"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone_number"
    t.string   "gender",                                  :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "remedy_insured",                                       :default => false
    t.boolean  "newsletter",                                           :default => false
    t.integer  "bar_association_id"
    t.string   "company_url"
    t.string   "company_name"
    t.text     "referral_source"
    t.boolean  "profession_advocate",                                  :default => false
    t.boolean  "profession_mediator",                                  :default => false
    t.boolean  "profession_notary",                                    :default => false
    t.boolean  "profession_tax_accountant",                            :default => false
    t.boolean  "profession_patent_attorney",                           :default => false
    t.boolean  "profession_cpa",                                       :default => false
    t.boolean  "profession_affiant_accountant",                        :default => false
    t.integer  "primary_expertise_id"
    t.integer  "secondary_expertise_id"
    t.string   "fax_number"
    t.string   "media"
    t.boolean  "publisher",                                            :default => false
    t.integer  "academic_title_id"
    t.integer  "tertiary_expertise_id"
    t.integer  "premium_contacts_count",                               :default => 0,     :null => false
    t.integer  "promotion_contacts_count",                             :default => 0,     :null => false
    t.float    "grade_point_average"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.text     "bio"
    t.string   "anglo_title"
    t.string   "position_name"
    t.date     "accredited_on"
    t.string   "occupational_title"
    t.string   "authorized_representative"
    t.string   "professional_indemnity"
    t.text     "company_information"
    t.text     "company_locations"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "skype_name"
    t.string   "twitter_name"
    t.string   "facebook_name"
    t.string   "xing_name"
    t.string   "linkedin_name"
    t.string   "company_office_hours"
    t.string   "company_parking_lots"
    t.string   "company_taxi_stands"
    t.string   "company_public_transportation"
    t.string   "company_additional_location_information"
    t.string   "preferred_payment_method"
    t.string   "paypal_account"
    t.string   "bank_account_owner_name"
    t.string   "bank_account_number"
    t.string   "bank_routing_number"
    t.string   "bank_name"
    t.string   "bank_location"
    t.string   "preferred_billing_method"
    t.string   "tax_number"
    t.integer  "company_size"
    t.string   "company_type"
    t.string   "company_headquarter"
    t.string   "rescue_phone_number"
    t.string   "anglo_title_type"
    t.string   "register_name"
    t.string   "register_number"
    t.boolean  "send_evaluate_message",                                :default => false
    t.integer  "overdrawn_contacts_count",                             :default => 0,     :null => false
    t.integer  "visits_count",                                         :default => 0,     :null => false
    t.string   "province_code"
    t.float    "lat"
    t.float    "lng"
    t.integer  "views_count",                                          :default => 0
  end

  add_index "people", ["bar_association_id"], :name => "index_people_on_bar_association_id"
  add_index "people", ["grade_point_average"], :name => "index_people_on_grade_point_average"
  add_index "people", ["lat", "lng"], :name => "index_people_on_lat_and_lng"
  add_index "people", ["overdrawn_contacts_count"], :name => "index_people_on_overdrawn_contacts_count"
  add_index "people", ["primary_expertise_id"], :name => "index_people_on_primary_expertise_id"
  add_index "people", ["profession_advocate"], :name => "index_people_on_profession_advocate"
  add_index "people", ["profession_affiant_accountant"], :name => "index_people_on_profession_affiant_accountant"
  add_index "people", ["profession_cpa"], :name => "index_people_on_profession_cpa"
  add_index "people", ["profession_mediator"], :name => "index_people_on_profession_mediator"
  add_index "people", ["profession_notary"], :name => "index_people_on_profession_notary"
  add_index "people", ["profession_patent_attorney"], :name => "index_people_on_profession_patent_attorney"
  add_index "people", ["profession_tax_accountant"], :name => "index_people_on_profession_tax_accountant"
  add_index "people", ["province_code"], :name => "index_people_on_province_code"
  add_index "people", ["publisher"], :name => "index_people_on_author"
  add_index "people", ["secondary_expertise_id"], :name => "index_people_on_secondary_expertise_id"
  add_index "people", ["tertiary_expertise_id"], :name => "index_people_on_tertiary_expertise_id"
  add_index "people", ["views_count"], :name => "index_people_on_views_count"
  add_index "people", ["visits_count"], :name => "index_people_on_visits_count"

  create_table "people_spoken_languages", :id => false, :force => true do |t|
    t.integer "person_id"
    t.integer "spoken_language_id"
  end

  add_index "people_spoken_languages", ["person_id", "spoken_language_id"], :name => "fk_person_language"

  create_table "products", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "cents",                         :default => 0,     :null => false
    t.string   "currency",         :limit => 3, :default => "EUR", :null => false
    t.string   "sku"
    t.integer  "contacts"
    t.integer  "position"
    t.boolean  "active",                        :default => true,  :null => false
    t.boolean  "subscription",                  :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "length_in_issues",              :default => 0,     :null => false
    t.boolean  "flat",                          :default => false, :null => false
    t.integer  "term_in_days"
    t.float    "tax_rate",                      :default => 19.0,  :null => false
  end

  add_index "products", ["active"], :name => "index_products_on_active"
  add_index "products", ["cents", "currency"], :name => "index_products_on_cents_and_currency"
  add_index "products", ["contacts"], :name => "index_products_on_contacts"
  add_index "products", ["flat"], :name => "index_products_on_flat"
  add_index "products", ["name"], :name => "index_products_on_name"
  add_index "products", ["position"], :name => "index_products_on_position"
  add_index "products", ["sku"], :name => "index_products_on_sku"
  add_index "products", ["subscription"], :name => "index_products_on_subscription"

  create_table "ratings", :force => true do |t|
    t.integer  "rating"
    t.integer  "rater_id"
    t.integer  "rateable_id",   :null => false
    t.string   "rateable_type", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["rateable_id", "rating"], :name => "index_ratings_on_rateable_id_and_rating"
  add_index "ratings", ["rater_id"], :name => "index_ratings_on_rater_id"

  create_table "readings", :force => true do |t|
    t.string   "readable_type"
    t.integer  "readable_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "readings", ["person_id"], :name => "index_readings_on_person_id"
  add_index "readings", ["readable_id", "readable_type"], :name => "index_readings_on_readable_id_and_readable_type"

  create_table "responses", :force => true do |t|
    t.integer  "kase_id"
    t.integer  "person_id"
    t.text     "description"
    t.string   "status",               :default => "created", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "close_reason"
    t.string   "close_description"
    t.datetime "advocate_reminded_at"
  end

  add_index "responses", ["advocate_reminded_at"], :name => "index_responses_on_advocate_reminded_at"
  add_index "responses", ["kase_id"], :name => "index_responses_on_kase_id"
  add_index "responses", ["person_id"], :name => "index_responses_on_person_id"
  add_index "responses", ["status"], :name => "index_responses_on_status"

  create_table "reviews", :force => true do |t|
    t.integer  "v"
    t.integer  "v1"
    t.integer  "v2"
    t.integer  "v3"
    t.integer  "v4"
    t.integer  "v5"
    t.integer  "z"
    t.integer  "z1"
    t.integer  "z2"
    t.integer  "z3"
    t.integer  "z4"
    t.integer  "z5"
    t.integer  "m"
    t.integer  "m1"
    t.integer  "m2"
    t.integer  "m3"
    t.integer  "m4"
    t.integer  "m5"
    t.integer  "e"
    t.integer  "e1"
    t.integer  "e2"
    t.integer  "e3"
    t.integer  "e4"
    t.integer  "e5"
    t.integer  "a"
    t.integer  "a1"
    t.integer  "a2"
    t.integer  "a3"
    t.integer  "a4"
    t.integer  "a5"
    t.float    "grade"
    t.string   "like_description"
    t.string   "dislike_description"
    t.string   "search_reason"
    t.boolean  "friend_recommend"
    t.boolean  "remedy_insured"
    t.date     "last_advocate_contact"
    t.string   "advocate_contact_count"
    t.string   "laswsuit_won"
    t.boolean  "allow_questions"
    t.string   "type"
    t.string   "status",                 :default => "created", :null => false
    t.integer  "reviewer_id"
    t.integer  "reviewee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "preapproved_at"
    t.datetime "opened_at"
    t.datetime "closed_at"
    t.float    "grade_point_average"
  end

  add_index "reviews", ["closed_at"], :name => "index_reviews_on_closed_at"
  add_index "reviews", ["grade_point_average"], :name => "index_reviews_on_grade_point_average"
  add_index "reviews", ["opened_at"], :name => "index_reviews_on_opened_at"
  add_index "reviews", ["reviewee_id"], :name => "index_reviews_on_reviewee_id"
  add_index "reviews", ["reviewer_id"], :name => "index_reviews_on_reviewer_id"
  add_index "reviews", ["status"], :name => "index_reviews_on_status"
  add_index "reviews", ["type"], :name => "index_reviews_on_type"

  create_table "search_filters", :force => true do |t|
    t.integer  "person_id"
    t.string   "tags"
    t.integer  "postal_code"
    t.integer  "radius"
    t.string   "province_code"
    t.float    "lat"
    t.float    "lng"
    t.string   "digest",        :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "city"
    t.datetime "digested_at"
    t.string   "finder_type"
    t.string   "type"
    t.string   "person_name"
  end

  add_index "search_filters", ["city"], :name => "index_search_filters_on_city"
  add_index "search_filters", ["digested_at"], :name => "index_search_filters_on_digested_at"
  add_index "search_filters", ["finder_type"], :name => "index_search_filters_on_finder_type"
  add_index "search_filters", ["lat", "lng"], :name => "index_search_filters_on_lat_and_lng"
  add_index "search_filters", ["person_id"], :name => "index_search_filters_on_person_id"
  add_index "search_filters", ["type"], :name => "index_search_filters_on_type"

  create_table "search_filters_topics", :id => false, :force => true do |t|
    t.integer "search_filter_id"
    t.integer "topic_id"
  end

  add_index "search_filters_topics", ["search_filter_id", "topic_id"], :name => "index_search_filters_topics_on_search_filter_id_and_topic_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "spoken_languages", :force => true do |t|
    t.string   "name"
    t.string   "code",       :limit => 3
    t.boolean  "priority",                :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spoken_languages", ["code"], :name => "index_spoken_languages_on_code"
  add_index "spoken_languages", ["name"], :name => "index_spoken_languages_on_name"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "topics", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.string   "type"
    t.boolean  "expertise_only", :default => true, :null => false
    t.boolean  "topic_only",     :default => true, :null => false
  end

  add_index "topics", ["expertise_only"], :name => "index_topics_on_expertise_only"
  add_index "topics", ["position"], :name => "index_topics_on_position"
  add_index "topics", ["topic_only"], :name => "index_topics_on_topic_only"
  add_index "topics", ["type"], :name => "index_topics_on_type"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.string   "activation_code",           :limit => 40
    t.string   "state",                                   :default => "passive"
    t.boolean  "persist",                                 :default => true
    t.integer  "person_id"
    t.datetime "deleted_at"
    t.datetime "activated_at"
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "password_is_generated",                   :default => false,     :null => false
    t.string   "reset_code"
  end

  add_index "users", ["password_is_generated"], :name => "index_users_on_password_is_generated"
  add_index "users", ["person_id"], :name => "index_users_on_person_id"
  add_index "users", ["reset_code"], :name => "index_users_on_reset_code"

  create_table "visits", :force => true do |t|
    t.integer  "visitor_id"
    t.integer  "visited_id"
    t.string   "visited_type"
    t.datetime "created_at"
    t.string   "uuid"
    t.boolean  "unique",       :default => false, :null => false
  end

  add_index "visits", ["unique"], :name => "index_visits_on_unique"
  add_index "visits", ["uuid"], :name => "index_visits_on_uuid"
  add_index "visits", ["visited_id", "visited_type"], :name => "index_visits_on_visited_id_and_visited_type"
  add_index "visits", ["visitor_id"], :name => "index_visits_on_visitor_id"

  create_table "voucher_redemptions", :force => true do |t|
    t.integer  "voucher_id"
    t.integer  "person_id"
    t.datetime "redeemed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "voucher_redemptions", ["person_id"], :name => "index_voucher_redemptions_on_person_id"
  add_index "voucher_redemptions", ["voucher_id"], :name => "index_voucher_redemptions_on_voucher_id"

  create_table "vouchers", :force => true do |t|
    t.integer  "consignor_id"
    t.integer  "consignee_id"
    t.integer  "promotable_id"
    t.string   "promotable_type"
    t.string   "promotable_sku"
    t.string   "code"
    t.string   "uuid"
    t.string   "uuid_base"
    t.string   "email"
    t.string   "timestamp"
    t.integer  "batch"
    t.string   "mac_address"
    t.datetime "created_at"
    t.datetime "expires_at"
    t.datetime "redeemed_at"
    t.integer  "cents",                            :default => 0,     :null => false
    t.string   "currency",            :limit => 3, :default => "USD", :null => false
    t.string   "type"
    t.integer  "amount",                           :default => 1,     :null => false
    t.boolean  "multiple_redeemable",              :default => false, :null => false
  end

  add_index "vouchers", ["code"], :name => "index_vouchers_on_code"
  add_index "vouchers", ["consignee_id"], :name => "index_vouchers_on_consignee_id"
  add_index "vouchers", ["consignor_id"], :name => "index_vouchers_on_consignor_id"
  add_index "vouchers", ["email"], :name => "index_vouchers_on_email"
  add_index "vouchers", ["multiple_redeemable"], :name => "index_vouchers_on_multiple_redeemable"
  add_index "vouchers", ["promotable_id", "promotable_type"], :name => "fk_vouchers_promotable"
  add_index "vouchers", ["type"], :name => "index_vouchers_on_type"
  add_index "vouchers", ["uuid"], :name => "index_vouchers_on_uuid"

end
