class AuditDatatable < AjaxDatatablesRails::Base
  def_delegators :@view, :display_audited_item_url, :display_whodunnit_email

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= [
        'Audit.item_type',
        'Audit.event',
        'Audit.whodunnit'
    ]
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= [
        'Audit.item_type',
        'Audit.event',
        'Audit.whodunnit_email',
        'Audit.whodunnit_name',
    ]
  end

  private

  def data
    records.map do |record|
      {
          # comma separated list of the values for each cell of a table row
          # example: record.attribute,
          '0' => display_audited_item_url(record),
          '1' => record.event,
          '2' => display_whodunnit_email(record),
          '3' => record.created_at.to_s(:created_on_formatted),
          'DT_RowId' => "audit-#{record.id}"
      }
    end
  end

  def get_raw_records
    #Audit.select('any_value(id), any_value(item_type), item_id, any_value(event), any_value(whodunnit), max(created_at)').group(:item_id) #.maximum(:created_at)
    Audit.all.order(created_at: :desc)
  end
# max(created_at)
# ==== Insert 'presenter'-like methods below if necessary
end
