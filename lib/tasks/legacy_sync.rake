# lib/tasks/legacy_sync.rake
namespace :user do
  desc 'Load new users into perid_umndid'
  task load_users: :environment do
    new_per_ids = Legacy::Yourl.where('per_id NOT IN (?)', PeridUmndid.all.pluck(:perid).uniq).pluck(:per_id).uniq
    new_user_total = new_per_ids.count
    puts "New users: #{new_user_total}"
    new_per_ids.each_with_index do |per_id, index|
      PeridUmndid.create(perid: per_id)
      puts "Added #{index + 1}/#{new_user_total}"
    end
  end

  desc 'Find umndid for the per ids'
  task update_umndids: :environment do
    total = PeridUmndid.where('umndid IS ?', nil).count
    PeridUmndid.where('umndid IS ?', nil).each_with_index do |perid_umndid, index|
      person = Legacy::Person.where(PER_ID: perid_umndid.perid).take
      next unless person.present?
      puts "Processing #{person.UID}"
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
    puts "Syncing #{Legacy::Yourl.count} URLs..."
    unknown_group = Group.find_or_create_by(
      name: 'Unknown Owners',
      description: 'Admin group for unknown URLs fk39wkoim9329jrlsdjfslaj824'
    )
    Legacy::Yourl.all.each_with_index do |yourl, index|
      next if Url.where(keyword: yourl.keyword).exists?
      puts "Moving over yourl #{yourl.keyword}"
      puts '-----------------------------'
      umndid = PeridUmndid.where(perid: yourl.per_id).take.umndid
      group_id = if umndid.present?
                   User.find_or_create_by(uid: umndid).default_group_id
                 else
                   unknown_group.id
                 end
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
        group_id: group_id
      )
    end
  end

  desc 'Ensure the URLs click counts are synced and update them accordingly'
  task update_clicks: :environment do
    Url.all.each do |url|
      # Move onto next URL if the click counts match
      legacy_click_total = Legacy::Click.where(shorturl: url.keyword).count
      next if url.clicks.size == legacy_click_total
      puts '---------------------------------'
      puts "Deleting current clicks for #{url.keyword}..."
      Click.where(url_id: url.id).delete_all
      url_id = url.id
      puts "Loading #{legacy_click_total} clicks for #{url.keyword}..."
      Legacy::Click.where(shorturl: url.keyword).each_with_index do |legacy_click, index|
        ActiveRecord::Base.connection.execute(
          "INSERT INTO `clicks` (`country_code`, `url_id`, `created_at`, `updated_at`) VALUES ('#{legacy_click.country_code}', #{url_id}, '#{legacy_click.click_time.to_s(:db)}', '#{Time.now.to_s(:db)}')"
        )
        puts "[#{url.keyword}]: Adding click #{index + 1}/#{legacy_click_total}"
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
