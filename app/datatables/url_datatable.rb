class UrlDatatable < AjaxDatatablesRails::Base

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= [
      'Url.url',
      'Url.keyword',
      'Url.total_clicks',
      'Url.created_at'
    ]
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= [
      'Url.url',
      'Url.keyword'
    ]
  end

  private

  def data
    records.map do |record|
      [
        # comma separated list of the values for each cell of a table row
        # example: record.attribute,
        record.url,
        record.keyword,
        record.total_clicks,
        record.created_at
      ]
    end
  end

  def get_raw_records
    Url.created_by_id(current_user.context_group_id)
       .not_in_pending_transfer_request
  end

  # ==== Insert 'presenter'-like methods below if necessary

  def current_user
    @current_user ||= options[:current_user]
  end
end
