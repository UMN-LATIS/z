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
  [{ uid: 'zx8gky5wf' },
   { uid: '2qggnq4v3' },
   { uid: '46suz2aru' },
   { uid: '3dci3yxub' },
   { uid: '5scyi59j8', admin: true }]
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
      url: 'http://www.google.com',
      keyword: 'goog',
      total_clicks: 9,
      group: User.first.context_group
    },
    {
      url: 'http://www.umn.edu',
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
