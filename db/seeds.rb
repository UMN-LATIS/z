# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

users = User.create([
	{uid: "wozniak"},
  {uid: "ebf"},
	{uid: "andersen"}
	])

other_groups = Group.create([
	{name: "LATIS", description: "This is the LATIS test group"},
	{name: "DCL", description: "This is the DCL test group"},
	{name: "CLA PR", description: "This is the CLA PR test group"},
	{name: "DASH", description: "This is the DASH test group"}
	])

urls = Url.create([
	{url: "google.com", keyword: "goog", total_clicks: 9, group: User.first.context_group},
	{url: "umn.edu", keyword: "umn", total_clicks: 3, group: User.last.context_group}
	])

clicks = Click.create([
	{country_code: "US", url_id: Url.first},
	{country_code: "US", url_id: Url.first},
	{country_code: "US", url_id: Url.first},
	{country_code: "CA", url_id: Url.first},
	{country_code: "UZ", url_id: Url.first},
	{country_code: "CA", url_id: Url.first},
	{country_code: "RU", url_id: Url.first},
	{country_code: "CU", url_id: Url.first},
	{country_code: "RU", url_id: Url.first},
	{country_code: "CN", url_id: Url.last},
	{country_code: "CN", url_id: Url.last},
	{country_code: "CN", url_id: Url.last}
	])
