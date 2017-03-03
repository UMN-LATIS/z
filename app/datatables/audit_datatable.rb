class AuditDatatable < AjaxDatatablesRails::Base
#  def_delegators :@view, :link_to, :full_url, :display_url

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
    records.each do |record|

      version = PaperTrail::Version.where_object(id: record.id)

      record.item_type = 'x'
      who = User.find_by(id: record.whodunnit)
      record.whodunnit = who ?  who.user_full_name : 'unkknown'
    end

    records.map do |record|
      {
          # comma separated list of the values for each cell of a table row
          # example: record.attribute,
          '0' => record.item_type,
          '1' => record.event,
          '2' => record.whodunnit,
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
