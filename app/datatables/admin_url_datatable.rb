class AdminUrlDatatable < ApplicationDatatable
  def_delegators :@view, :link_to, :full_url, :display_long_url, :display_keyword_url, :select_tag,
                 :options_from_collection_for_select, :url_path, :render

  def view_columns
    @view_columns ||= {
      id: { source: 'Url.id' },
      group_id: { source: 'Url.group_id' },
      group_name: { source: 'Group.name' },
      is_default_group: { source: 'Group.default?' },
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
        id: record.id,
        group_id: record.group_id,
        group_name: record.group.name,
        is_default_group: record.group.default?,
        url: record.url,
        keyword: record.keyword,
        total_clicks: record.total_clicks,
        created_at: record.created_at.to_s(:created_on_formatted)
      }
    end
  end

  def get_raw_records
    Url.includes(:group).references(:group)
  end

  # ==== Insert 'presenter'-like methods below if necessary
end
