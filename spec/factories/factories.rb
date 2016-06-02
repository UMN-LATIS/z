FactoryGirl.define do
  factory :user do
    sequence(:uid)
    admin false

    factory :admin do
      admin true
    end
  end

  factory :url do
    url 'http://google.com'
  end
end
