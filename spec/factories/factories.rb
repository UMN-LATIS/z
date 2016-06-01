FactoryGirl.define do
  factory :user do
		sequence(:uid) { |n| "#{n}" }
    admin false
		
		factory :admin do
			admin	true
		end
  end
	
	factory :url do
		url "http://google.com"
	end
	
	
end
#  id          :integer          not null, primary key
#  url         :string(255)
#  keyword     :string(255)
#  total_clicks      :integer
#  group_id    :integer
#  modified_by :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
