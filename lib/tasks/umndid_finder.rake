# lib/tasks/db.rake
namespace :user do
  desc 'Find umndid for the per ids'
  task update_umndids: :environment do
    PeridUmndid.where('umndid IS ?', nil).each do |perid_umndid|
      puts "--------------------------------"
      puts "looking for #{perid_umndid.perid}"
      person = Legacy::Person.where(PER_ID:11440414).take
      if person.present?
        perid_umndid.umndid = UserLookupService.new(
                       query: 'smit9049',
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
