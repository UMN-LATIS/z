# lib/tasks/umndid_finder.rake
namespace :user do
  desc 'Find umndid for the per ids'
  task update_umndids: :environment do
    PeridUmndid.where('umndid IS ?', nil).each do |perid_umndid|
      person = Legacy::Person.where(PER_ID: perid_umndid.perid).take
      next unless person.present?
      perid_umndid.umndid = UserLookupService.new(
        query: person.UID,
        query_type: 'uid'
      ).search.try(:first).try(:first).try(:last).try(:first)
      perid_umndid.save if perid_umndid.umndid.present?
    end
  end
end

namespace :urls do
  desc 'Add urls for known per_ids'
  task import_urls: :environment do
    Legacy::Yourl.find_each.with_index do |yourl, index|
      Benchmark.bm(7) do |x|
        next if Url.where(keyword: yourl.keyword).count.blank?
        user = nil
        umndid = nil
        puts "Moving yourl #{yourl.keyword}"
        puts '-----------------------------'
          x.report('user lookup') do
            umndid = PeridUmndid.where(perid: yourl.per_id).take.umndid
          end
          if umndid.present?
            x.report("user create") do
              user = User.find_or_create_by(
                uid: umndid
              )
            end
          else
            x.report('user not present') do
              user = User.where(uid: '5scyi59j8').take
            end
          end
          next unless user.present?
        parsed_url = nil
        x.report('url parse') do
          parsed_url = yourl.url.delete("^\u{0000}-\u{007F}")
          parsed_url = 'http://z.umn.edu' unless valid_url?(parsed_url)
          begin
            parsed_url = URI.parse(URI.encode(parsed_url.strip)).to_s
          rescue URI::InvalidURIError
            parsed_url = 'http://z.umn.edu'
          end
        end
        x.report('url create') do
          Url.find_or_create_by(
            url: parsed_url,
            keyword: yourl.keyword,
            created_at: yourl.timestamp,
            total_clicks: yourl.clicks,
            group_id: user.default_group_id
          )
        end
      end
    end
  end
  task update_clicks: :environment do
    Url.find_each do |url|
      next if url.clicks.size > 0
      puts '---------------------------------'
      puts "adding clicks for #{url.keyword}"
      url_id = url.id
      Legacy::Click.where(shorturl: url.keyword).find_each do |legacy_click|
        ActiveRecord::Base.connection.execute("INSERT INTO `clicks` (`country_code`, `url_id`, `created_at`, `updated_at`) VALUES ('#{legacy_click.country_code}', #{url_id}, '#{legacy_click.click_time.to_s(:db)}', '#{Time.now.to_s(:db)}')")
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
