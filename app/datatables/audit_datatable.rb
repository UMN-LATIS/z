class AuditDatatable < AjaxDatatablesRails::Base
  def_delegators :@view, :display_whodunnit_internet_id

  def view_columns
    @view_columns ||= {
        item_type: { source: 'Audit.item_type' },
        event: { source: 'Audit.event' },
        whodunnit: { source: 'Audit.whodunnit' },
        audit_history: { source: 'Audit.version_history' },
        created_at: { source: 'Audit.created_at' }
    }
  end
  private

  def data
    visited = []
    posi = []
    records.each do |record|
      next if visited.include? "#{record.item_id}-#{record.item_type}"
      visited << "#{record.item_id}-#{record.item_type}"
      posi << record
    end
    records = posi
    records.map do |record|
      {
          # comma separated list of the values for each cell of a table row
          # example: record.attribute,
          item_type: record.item_type,
          event: record.event,
          whodunnit: display_whodunnit_internet_id(record),
          audit_history: record.version_history,
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
