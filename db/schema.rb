# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_08_04_150047) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "badges", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.text "condition_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name"
    t.text "notes"
    t.bigint "user_id", null: false
    t.bigint "relationship_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "contact_user_id"
    t.string "photo_name"
    t.index ["contact_user_id"], name: "index_contacts_on_contact_user_id"
    t.index ["relationship_id"], name: "index_contacts_on_relationship_id"
    t.index ["user_id"], name: "index_contacts_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "contact_id"
    t.bigint "user1_id"
    t.bigint "user2_id"
    t.index ["contact_id"], name: "index_conversations_on_contact_id"
    t.index ["user1_id"], name: "index_conversations_on_user1_id"
    t.index ["user2_id"], name: "index_conversations_on_user2_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.date "sent_at"
    t.bigint "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "ai_draft"
    t.integer "status", default: 0
    t.boolean "dismissed"
    t.bigint "conversation_id"
    t.bigint "sender_id"
    t.bigint "receiver_id"
    t.bigint "user_id"
    t.index ["contact_id"], name: "index_messages_on_contact_id"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "relationships", force: :cascade do |t|
    t.string "relation_type"
    t.integer "proximity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.text "channel"
    t.text "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.binary "key", null: false
    t.binary "value", null: false
    t.datetime "created_at", null: false
    t.bigint "key_hash", null: false
    t.integer "byte_size", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "user_badges", force: :cascade do |t|
    t.date "obtained_at"
    t.bigint "user_id", null: false
    t.bigint "badge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_id"], name: "index_user_badges_on_badge_id"
    t.index ["user_id"], name: "index_user_badges_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.text "address"
    t.string "username"
    t.string "phone_number"
    t.integer "xp_level", default: 0
    t.date "birth_date"
    t.integer "xp_points", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "contacts", "relationships"
  add_foreign_key "contacts", "users"
  add_foreign_key "contacts", "users", column: "contact_user_id"
  add_foreign_key "conversations", "contacts"
  add_foreign_key "conversations", "users", column: "user1_id"
  add_foreign_key "conversations", "users", column: "user2_id"
  add_foreign_key "messages", "contacts"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "user_badges", "badges"
  add_foreign_key "user_badges", "users"
end
