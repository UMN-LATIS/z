module AuditHelper
  def display_audited_item_url(audited_thing)
    link_to(audited_thing.item_type, admin_audit_url(audited_thing.id), target: '_blank')
  end

  def display_whodunnit_email(audited_thing)
    audited_thing.whodunnit_name ?  mail_to(audited_thing.whodunnit_email, audited_thing.whodunnit_name) : 'unknown'
  end
end
