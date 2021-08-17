# == Schema Information
#
# Table name: starburst_announcements
# id	int(11)	No
# title	text	Yes
# body	text	Yes
# start_delivering_at	datetime	Yes
# stop_delivering_at	datetime	Yes
# limit_to_users	text	Yes
# created_at	datetime	Yes
# updated_at	datetime	Yes
# category	text
require 'rails_helper'

RSpec.describe Admin::Announcement, type: :model do
  subject { @announcement }

  before do
    @announcement = FactoryBot.build(:announcement)
  end

  it { is_expected.to be_valid }
  it { is_expected.to respond_to 'title' }
  it { is_expected.to respond_to 'body' }
  it { is_expected.to respond_to 'stop_delivering_at' }
  it { is_expected.to respond_to 'start_delivering_at' }
end
