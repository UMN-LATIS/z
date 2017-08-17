module AuditHelper
  def display_whodunnit_internet_id(audited_thing)
    audited_thing.whodunnit ? User.find(audited_thing.whodunnit).internet_id : 'Unknown'
  end
end
