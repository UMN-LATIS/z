module AuditHelper
  def display_whodunnit_email(audited_thing)
    audited_thing.whodunnit_name ?  mail_to(audited_thing.whodunnit_email, audited_thing.whodunnit_name) : 'unknown'
  end
end
