FactoryGirl.define do
  factory :user do
    sequence(:uid)
    admin false
    sequence(:last_name) { |n| "last_name#{n}" }
    sequence(:first_name) { |n| "first_name#{n}" }
    sequence(:email) { |n| "email#{n}@umn.edu" }
    sequence(:internet_id) { |n| "internet_id#{n}" }
    sequence(:last_name_loaded) { |n| "last_name#{n}" }
    sequence(:first_name_loaded) { |n| "first_name#{n}" }
    sequence(:email_loaded) { |n| "email#{n}@umn.edu" }
    sequence(:internet_id_loaded) { |n| "internet_id#{n}" }

    factory :admin do
      admin true
    end
  end

  factory :audit do
    item_type	'url'
    item_id	'1'
    event	'create'
    whodunnit { FactoryGirl.create(:user) }
    object	'test_keyword'
    whodunnit_email 'abc.def,com'
    whodunnit_name	'Julia Child'
  end

  factory :url do
    url 'http://google.com'
    sequence(:keyword) { |n| "keyword#{n}" }
    group { FactoryGirl.create(:user).context_group }
  end

  factory :announcement, :class => Admin::Announcement do
    title	'Whoa Nelly!'
    body	'The Court is in Session, here comes the judge!'
    start_delivering_at	(DateTime.now - 30.days).strftime("%Y-%m-%d")
    stop_delivering_at (DateTime.now + 30.days).strftime("%Y-%m-%d") 
  end

  factory :group do
    name 'My First Group'
    description 'first group of urls'
  end

  factory :transfer_request do
    from_user { FactoryGirl.create(:user) }
    to_user { FactoryGirl.create(:user) }
    to_group { to_user.default_group }
    from_group { from_user.default_group }

    urls { [FactoryGirl.create(:url, group: from_group)] }
  end

  factory :frequently_asked_question do
    header "Header"
    question "Question"
    answer "Answer"
  end
end
