# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:uid)
    admin { false }
    sequence(:display_name_loaded) { |n| "first_name#{n}" }
    sequence(:internet_id_loaded) { |n| "internet_id#{n}" }

    factory :admin do
      admin { true }
    end
  end

  factory :audit do
    item_type	{ 'url' }
    item_id	{ '1' }
    event	{ 'create' }
    whodunnit { FactoryBot.create(:user) }
    object	{ 'test_keyword' }
    whodunnit_email { 'abc.def,com' }
    whodunnit_name { 'Julia Child' }
  end

  factory :url do
    url { 'http://google.com' }
    sequence(:keyword) { |n| "keyword#{n}" }
    group { FactoryBot.create(:user).context_group }
  end

  factory :announcement, class: 'Admin::Announcement' do
    title	{ 'Whoa Nelly!' }
    body { 'The Court is in Session, here comes the judge!' }
    start_delivering_at	{ (DateTime.now - 30.days).strftime("%Y-%m-%d") }
    stop_delivering_at { (DateTime.now + 30.days).strftime("%Y-%m-%d") }
  end

  factory :group do
    sequence(:name) { |n| "group_name#{n}" }
    sequence(:description) { |n| "group_descr#{n}" }
  end

  factory :transfer_request do
    from_user { FactoryBot.create(:user) }
    to_user { FactoryBot.create(:user) }
    to_group { to_user.default_group }
    from_group { from_user.default_group }

    urls { [FactoryBot.create(:url, group: from_group)] }
  end

  factory :frequently_asked_question do
    header { "Header" }
    question { "Question" }
    answer { "Answer" }
  end
end

def create_url_for_user(user, factory_opts = nil)
  url = FactoryBot.create(:url, factory_opts)
  url.update(group: user.context_group)
end
