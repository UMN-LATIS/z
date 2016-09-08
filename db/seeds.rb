# This file should contain all the record creation needed to seed the
# database with its default values.
# The data can then be loaded with the rails db:seed command
# (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create(
#     [
#       { name: 'Star Wars' }, {  name: 'Lord of the Rings' }
#     ]
#   )
#   Character.create(name: 'Luke', movie: movies.first)

User.create(
  [{ uid: 'wozniak', provider: 'developer' },
   { uid: 'ebf', provider: 'developer' },
   { uid: 'andersen', provider: 'developer' },
   { uid: 'admin', provider: 'developer', admin: true}]
)

Group.create(
  [{ name: 'LATIS', description: 'This is the LATIS test group' },
   { name: 'DCL', description: 'This is the DCL test group' },
   { name: 'CLA PR', description: 'This is the CLA PR test group' },
   { name: 'DASH', description: 'This is the DASH test group' }]
)

Url.create(
  [
    {
      url: 'google.com',
      keyword: 'goog',
      total_clicks: 9,
      group: User.first.context_group
    },
    {
      url: 'umn.edu',
      keyword: 'umn',
      total_clicks: 3,
      group: User.last.context_group
    }
  ]
)

Click.create(
  [{ country_code: 'US', url_id: Url.first.id },
   { country_code: 'US', url_id: Url.first.id },
   { country_code: 'US', url_id: Url.first.id },
   { country_code: 'CA', url_id: Url.first.id },
   { country_code: 'UZ', url_id: Url.first.id },
   { country_code: 'CA', url_id: Url.first.id },
   { country_code: 'RU', url_id: Url.first.id },
   { country_code: 'CU', url_id: Url.first.id },
   { country_code: 'RU', url_id: Url.first.id },
   { country_code: 'CN', url_id: Url.last.id },
   { country_code: 'CN', url_id: Url.last.id },
   { country_code: 'CN', url_id: Url.last.id }]
)
