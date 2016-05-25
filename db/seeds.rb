# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

users = User.create([
	{uid: "rossx275"},
	{uid: "wozniak"},
	{uid: "tdbeder"},
	{uid: "andersen"}
	])
	
other_groups = Group.create([
	{name: "LATIS", description: "This is the LATIS test group"},
	{name: "DCL", description: "This is the DCL test group"},
	{name: "CLA PR", description: "This is the CLA PR test group"},
	{name: "DASH", description: "This is the DASH test group"}
	])
	
urls = Url.create([
	{url: "google.com", keyword: "goog", total_clicks: 7, group: User.first.context_group},
	{url: "umn.edu", keyword: "umn", total_clicks: 3, group: User.last.context_group}
	])	

clicks = Click.create([
	{country_code: "US", url_id: Url.first},
	{country_code: "US", url_id: Url.first},
	{country_code: "US", url_id: Url.first},
	{country_code: "US", url_id: Url.first},
	{country_code: "US", url_id: Url.first},
	{country_code: "US", url_id: Url.first},
	{country_code: "US", url_id: Url.first},
	{country_code: "US", url_id: Url.last},
	{country_code: "US", url_id: Url.last},
	{country_code: "US", url_id: Url.last}
	])
