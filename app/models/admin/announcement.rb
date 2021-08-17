# == Schema Information
#
# Table name: starburst_announcements
#
# id	int(11)	No
# title	text	Yes
# body	text	Yes
# start_delivering_at	datetime	Yes
# stop_delivering_at	datetime	Yes
# limit_to_users	text	Yes
# created_at	datetime	Yes
# updated_at	datetime	Yes
# category	text	Yes

# models/announcement.rb
class Admin::Announcement < ApplicationRecord
  self.table_name = 'starburst_announcements'
end
