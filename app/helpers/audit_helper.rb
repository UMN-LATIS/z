module AuditHelper
  def display_audited_item_url(audited_thing)
    link_to(audited_thing.item_type, admin_audit_url(audited_thing.id), target: '_blank')
  end

  def display_whodunnit_email(audited_thing)
    who = User.find_by(id: audited_thing.whodunnit)
    who ?  mail_to(who.email, who.user_full_name) : 'unknown'
  end
end
