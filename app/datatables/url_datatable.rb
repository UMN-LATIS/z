class UrlDatatable < AjaxDatatablesRails::Base

  def_delegators :@view, :link_to, :full_url

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
      {
        # comma separated list of the values for each cell of a table row
        # example: record.attribute,
        '0' => nil,
        '1' => link_to(record.url, record.url, target: '_blank'),
        '2' => link_to(record.keyword, full_url(record), target: '_blank'),
        '3' => record.total_clicks,
        '4' => record.created_at.to_s(:created_on_formatted),
        'DT_RowData' => {'url' => record.url, 'keyword' => record.keyword}
      }
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
