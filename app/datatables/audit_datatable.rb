class AuditDatatable < AjaxDatatablesRails::Base
  def_delegators :@view, :link_to, :full_url, :display_url

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
          '0' => nil,
          '1' => display_audit_item(record),
          '2' => record.event,
          '3' => record.whodunit,
          '4' => record.created_at.to_s(:created_on_formatted),
          'DT_RowId' => "audit-#{record.id}"
      }
    end
  end

  def get_raw_records
   Audit.all
  end

  # ==== Insert 'presenter'-like methods below if necessary
end
