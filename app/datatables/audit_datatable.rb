class AuditDatatable < AjaxDatatablesRails::Base
  def_delegators :@view, :link_to, :display_audit_item_url, :display_whodunnit_url

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= [
        'item_type',
        'item_id',
        'event',
        'whodunnit'
    ]
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= [
        'item_type',
        'item_id',
        'event',
        'whodunnit'
    ]
  end

  private

  def data
    records.map do |record|
      {
          # comma separated list of the values for each cell of a table row
          # example: record.attribute,
          '0' => link_to(record.item_type, display_audit_item_url(record), target: '_blank'),
          '1' => record.event,
          '2' => display_whodunnit_url(record),
          '3' => record.created_at.to_s(:created_on_formatted),
          'DT_RowId' => "audit-#{record.id}"
      }
    end
  end
  def get_raw_records
   Audit.all #select('id, item_type, item_id, event, whodunnit, created_at')
  end

  # ==== Insert 'presenter'-like methods below if necessary
end
