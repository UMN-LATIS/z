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
    group { FactoryGirl.create(:user).context_group }
  end
end
