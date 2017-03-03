module AuditHelper

  def display_audit_item_url(audited_thing)
    admin_audit_url(audited_thing.id)
  end

  def display_whodunnit_url(audited_thing)
    who = User.find_by(id: audited_thing.whodunnit)
    who ?  who.user_full_name : 'unknown'
  end

end
