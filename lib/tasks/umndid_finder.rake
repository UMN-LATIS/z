# lib/tasks/db.rake
namespace :user do
  desc 'Find umndid for the per ids'
  task update_umndids: :environment do
    PeridUmndid.where('umndid IS ?', nil).each do |perid_umndid|
      puts "--------------------------------"
      puts "looking for #{perid_umndid.perid}"
      person = Legacy::Person.where(PER_ID:perid_umndid.perid).take
      if person.present?
        perid_umndid.umndid = UserLookupService.new(
                       query: person,
                       query_type: 'uid' #todo query_type: params[:search_type]
                   ).search.try(:first).try(:first).try(:last).try(:first)
        puts "found person"
        if perid_umndid.umndid.present?
          perid_umndid.save
          puts "found umndid DING DING DING"
        else
          puts "could not find umndid for this person"
        end
      else
        puts "not able to find this person in CLA DATA CENTER"
      end
    end
  end
end

namespace :urls do
  desc 'Add urls for known per_ids'
  task import_urls: :environment do
    Legacy::Yourl.all.each_with_index do |yourl, index|
      puts "#{index} - moving keyword: #{yourl.keyword}"
      next if Url.where(keyword: yourl.keyword).count.blank?
      umndid = PeridUmndid.where(perid: yourl.per_id).take.umndid
      if umndid.present?
        user = User.find_or_create_by(
          uid: umndid
        )
      else
        user = User.where(uid: '5scyi59j8').take
      end
      if user.present?
        parsed_url = yourl.url.delete("^\u{0000}-\u{007F}")
        if !valid_url?(parsed_url)
          parsed_url = 'http://z.umn.edu'
        end

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
  end
end

def valid_url?(url)
  schemes = %w(http https)
  parsed = Addressable::URI.parse(url) or return false
  schemes.include?(parsed.scheme)
  rescue Addressable::URI::InvalidURIError
    false
end