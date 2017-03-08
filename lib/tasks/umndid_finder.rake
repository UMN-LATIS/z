# lib/tasks/umndid_finder.rake
namespace :user do
  desc 'Find umndid for the per ids'
  task update_umndids: :environment do
    total = PeridUmndid.where('umndid IS ?', nil).count
    PeridUmndid.where('umndid IS ?', nil).each_with_index do |perid_umndid, index|
      person = Legacy::Person.where(PER_ID: perid_umndid.perid).take
      next unless person.present?
      perid_umndid.umndid = UserLookupService.new(
        query: person.UID,
        query_type: 'uid'
      ).search.try(:first).try(:first).try(:last).try(:first)
      perid_umndid.save if perid_umndid.umndid.present?
      puts "Processed #{index + 1}/#{total}"
    end
  end
end

namespace :urls do
  desc 'Add urls for known per_ids'
  task import_urls: :environment do
    Legacy::Yourl.find_each.with_index do |yourl, index|
      next unless Url.where(keyword: yourl.keyword).count.blank?
      puts "Moving yourl #{yourl.keyword}"
      puts '-----------------------------'
      umndid = PeridUmndid.where(perid: yourl.per_id).take.umndid
      user = if umndid.present?
               User.find_or_create_by(uid: umndid)
             else
               # This should be a generic user / or custom "Unknown" group id
               User.find_or_create_by(uid: '5scyi59j8')
             end
      next unless user.present?
      parsed_url = yourl.url.delete("^\u{0000}-\u{007F}")
      parsed_url = 'http://z.umn.edu' unless valid_url?(parsed_url)
      begin
        parsed_url = URI.parse(URI.encode(parsed_url.strip)).to_s
      rescue URI::InvalidURIError
        parsed_url = 'http://z.umn.edu'
      end
      Url.find_or_create_by(
        url: parsed_url,
        keyword: yourl.keyword,
        created_at: yourl.timestamp,
        total_clicks: yourl.clicks,
        group_id: user.default_group_id
      )
    end
  end
  task update_clicks: :environment do
    Url.find_each do |url|
      # Move onto next URL if the click counts match
      legacy_click_total = Legacy::Click.where(shorturl: url.keyword).count
      next if url.clicks.size == legacy_click_total
      puts '---------------------------------'
      puts "Adding clicks for #{url.keyword}"
      # Destroy current click count and rebuild
      url.clicks.destrroy_all
      url_id = url.id
      index = 1
      Legacy::Click.where(shorturl: url.keyword).find_each do |legacy_click|
        ActiveRecord::Base.connection.execute(
          "INSERT INTO `clicks` (`country_code`, `url_id`, `created_at`, `updated_at`) VALUES ('#{legacy_click.country_code}', #{url_id}, '#{legacy_click.click_time.to_s(:db)}', '#{Time.now.to_s(:db)}')"
        )
        puts "[#{url.keyword}: Adding click #{index}/#{legacy_click_total}"
        index += 1
      end
    end
  end
end

def valid_url?(url)
  schemes = %w(http https)
  parsed = Addressable::URI.parse(url) or return false
  schemes.include?(parsed.scheme)
rescue Addressable::URI::InvalidURIError
  false
end
