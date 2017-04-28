json.extract! admin_announcement, :id, :title, :body, :start_delivering_at, :stop_delivering_at, :created_at, :updated_at
json.url admin_announcement_url(admin_announcement, format: :json)
