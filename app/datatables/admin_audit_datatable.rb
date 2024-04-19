class AdminAuditDatatable < ApplicationDatatable
  def_delegators :@view

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
      user_internet_id = record.user.present? ? record.user.internet_id : "Unknown"

      {
        item_type: record.item_type,
        event: record.event,
        whodunnit: user_internet_id,
        audit_history: record.version_history,
        created_at: record.created_at.to_fs(:created_on_formatted),
        'DT_RowId' => "audit-#{record.id}"
      }
    end
  end

  def get_raw_records
    Audit.includes(:user)
  end
end
