class AdminUrlDatatable < AjaxDatatablesRails::Base
  def_delegators :@view, :link_to, :full_url, :display_long_url, :display_keyword_url, :select_tag, :options_from_collection_for_select, :url_path, :render

  def view_columns
    @view_columns ||= {
      group_id: { source: 'Url.group_id' },
      group_name: { source: 'Group.name' },
      url: { source: 'Url.url' },
      keyword: { source: 'Url.keyword' },
      total_clicks: { source: 'Url.total_clicks' },
      created_at: { source: 'Url.created_at' }
    }
  end

  private

  def data
    records.map do |record|
      {
        # comma separated list of the values for each cell of a table row
        # example: record.attribute,
        group_id: record.group_id,
        group_name: record.group.name,
        url: link_to(display_long_url(record.url), record.url, target: '_blank'),
        keyword: link_to(display_keyword_url(record.keyword), full_url(record), target: '_blank'),
        total_clicks: record.total_clicks,
        created_at: record.created_at.to_s(:created_on_formatted),
        actions: render(
          partial: 'urls/in_row_actions',
          locals: { url: record, admin_view: true }
        ),
        'DT_RowData' => { 'url' => record.url, 'keyword' => record.keyword },
        'DT_RowId' => "url-#{record.id}"
      }
    end
  end

  def get_raw_records
    Url.joins(:group)
  end

  # ==== Insert 'presenter'-like methods below if necessary
end
