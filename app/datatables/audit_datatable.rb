class AuditDatatable < AjaxDatatablesRails::Base
  def_delegators :@view, :display_audited_item_url, :display_whodunnit_email

  def view_columns
    @view_columns ||= {
        item_type: { source: 'Audit.item_type' },
        event: { source: 'Audit.event' },
        whodunnit: { source: 'Audit.whodunnit' },
        whodunnit_email: { source: 'Audit.whodunnit_email' },
        whodunnit_name: { source: 'Audit.whodunnit_name' },
        created_at: { source: 'Audit.created_at' }
    }
  end
  private

  def data
    records.map do |record|
      {
          # comma separated list of the values for each cell of a table row
          # example: record.attribute,
          item_type: display_audited_item_url(record),
          event: record.event,
          whodunnit: display_whodunnit_email(record),
          whodunnit_email: record.whodunnit_email,
          whodunnit_name: record.whodunnit_name,
          created_at: record.created_at.to_s(:created_on_formatted),
          'DT_RowId' => "audit-#{record.id}"
      }
    end
  end

  def get_raw_records
    Audit.order(created_at: :desc)
  end
# max(created_at)
# ==== Insert 'presenter'-like methods below if necessary
end
