# This migration comes from starburst (originally 20141209221904)
class AddIndexAndUniquenessToAnnouncementViews < ActiveRecord::Migration
  def change
  	add_index :starburst_announcement_views, [:user_id, :announcement_id], unique: true, name: 'starburst_announcement_view_index'
  end
end