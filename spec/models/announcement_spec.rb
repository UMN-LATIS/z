# == Schema Information
#
# Table name: starburst_announcements
=begin
id	int(11)	No
title	text	Yes
body	text	Yes
start_delivering_at	datetime	Yes
stop_delivering_at	datetime	Yes
limit_to_users	text	Yes
created_at	datetime	Yes
updated_at	datetime	Yes
category	text
=end
require 'rails_helper'

RSpec.describe Admin::Announcement, type: :model do
  before do
    @announcement = FactoryBot.build(:announcement)
  end

  subject { @announcement }

  it { should be_valid }
  it { should respond_to 'title' }
  it { should respond_to 'body' }
  it { should respond_to 'stop_delivering_at'}
  it { should respond_to 'start_delivering_at'}


end
