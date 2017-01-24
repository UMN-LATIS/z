FactoryGirl.define do
  factory :user do
    sequence(:uid)
    admin false
    sequence(:last_name) { |n| "last_name#{n}" }
    sequence(:first_name) { |n| "first_name#{n}" }
    sequence(:email) { |n| "email#{n}@umn.edu" }
    sequence(:internet_id) { |n| "internet_id#{n}" }

    factory :admin do
      admin true
    end
  end

  factory :url do
    url 'http://google.com'
    sequence(:keyword) { |n| "keyword#{n}" }
    group { FactoryGirl.create(:user).context_group }
  end

  factory :group do
    name 'My First Group'
    description 'first group of urls'
  end

  factory :transfer_request do
    to_group { FactoryGirl.create(:group) }
    from_group { FactoryGirl.create(:group) }
    user { FactoryGirl.create(:user) }
    urls { [FactoryGirl.create(:url, group: from_group)] }
  end
end
