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
if Rails.env.development?

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

end

FrequentlyAskedQuestion.create(
  [{ header: 'general', question: 'What is z.umn.edu (Z)?', answer: 'Z is a URL shortening service which allows for longer URLs to be be shortened. A shortened URL is helpful for social media, printed pieces, or just sharing with others.' },
   { header: 'general', question: 'When should I use z.umn.edu?',
     answer: 'We recommend using Z for cases in which you need a shortened URL for University-related content that will be published or posted for many users to view, or for material which may need to be retyped by users.' },
   { header: 'general', question: 'Who can create a Z link?',
     answer: 'Anybody with a University of Minnesota X500 login may create URLs. The URLs that are created are accessible to anyone, with no need for an X500 account. This means you can create a URL and share it with non-UMN audiences.' },
   { header: 'general', question: 'Are there limitations on the use of the “custom” field?',
     answer: 'We reserve the right to revoke “custom” URLs if the short name is intended to defraud or deceive, or if it is in violation of the University of Minnesota Acceptable Use policy. We recommend you avoid using custom URLs that are too generic or which may be confusing to users.' },
   { header: 'general', question: 'What if the custom URL I want is already in use?',
     answer: 'Once a URL has been claimed by creating a custom URL, no other URL can be created using the same URL.  If it looks like a URL is claimed, but no longer in use, you can reach out to us.  We’ll ask the current owner if they’re willing to relinquish it.' },
   { header: 'general', question: 'How long are URLs active?', answer: 'URLs never expire.' },
   { header: 'general', question: 'What happens to the URLs I created if I graduate or leave the U?',
     answer: 'The ownership of a URL can be transferred to another individual or group to ensure they can be updated and modified. The owner can do this themselves right from the site.' },
   { header: 'general', question: 'Is there a limit as to how many URLs I can create and have active?',
     answer: 'There is currently no limit, though we request that the service be used for U-related work/projects/events only.' },
   { header: 'general', question: 'What software does Z use?',
     answer: 'Z is an open source application developed by LATIS at the University of Minnesota.  You can view the source code and learn about installing it yourself at github.com/umn-latis/z.' },
   { header: 'general', question: 'How reliable are click counts for a given URL?',
     answer: 'In general, the Z counts should be reliable. The application itself definitely counts any time it redirects someone. We say "in general" because some browsers cache these types of redirects. So, if the same person clicked a given link a few times, with the same browser, Z might only count the first click.' }]
)
