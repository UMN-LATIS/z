FactoryGirl.define do
  factory :user do
    sequence(:uid)
    admin false
    provider 'developer'

    factory :admin do
      admin true
    end
  end

  factory :url do
    url 'http://google.com'
    sequence(:keyword) {|n| "keyword#{n}" }
    group { FactoryGirl.create(:user).context_group }
  end

  factory :group do
    name 'My First Group'
    description 'first group of urls'
  end

  factory :transfer_request do
    to_group { FactoryGirl.create(:group) }
    from_group { FactoryGirl.create(:group) }
    urls {[FactoryGirl.create(:url, group: from_group)]}
  end


end
