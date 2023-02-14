class UrlDatatable < ApplicationDatatable
  def_delegators :@view, :link_to, :full_url, :display_long_url, :display_keyword_url, :select_tag,
                 :options_for_select, :url_path, :render, :display_name, :group_names_and_ids_for_select

  def view_columns
    @view_columns ||= {
      # added to resolve `InvalidSearchColumn error`
      # Likely caused by ajax data tables looking for data
      # for the first checkbox select column
      # see: js method `initializeUrlDataTable()`
      '0': { searchable: false, orderable: false },
      group_id: { source: 'Url.group_id' },
      group_name: { source: 'Group.name' },
      url: { source: 'Url.url' },
      keyword: { source: 'Url.keyword' },
      total_clicks: { source: 'Url.total_clicks', searchable: false },
      created_at: { source: 'Url.created_at' },
      # needed for actions like edit, delete, etc.
      actions: { searchable: false, orderable: false }
    }
  end

  private

  def data
    user_groups_for_collection = group_names_and_ids_for_select(current_user.groups)
    records.map do |record|
      {
        # comma separated list of the values for each cell of a table row
        # example: record.attribute,
        group_id: record.group_id,
        group_name: select_tag(
          "url-collection-#{record.id}",
          options_for_select(
            user_groups_for_collection,
            record.group_id
          ),
          class: 'form-control selectpicker ',
          'aria-label': 'Current Collection',
          data: {
            update_path: url_path(record.id),
            keyword: record.keyword,
            group_id: record.group_id
          }
        ),
        url: link_to(display_long_url(record.url), record.url, target: '_blank', rel: 'noopener'),
        keyword: render(
          formats: [:html],
          partial: 'urls/short_url_table_cell',
          locals: { url: record }
        ),
        total_clicks: link_to(record.total_clicks, url_path(record.keyword), target: '_blank', rel: 'noopener'),
        created_at: record.created_at.to_s(:created_on_formatted),
        actions: render(
          formats: [:html],
          partial: 'urls/in_row_actions',
          locals: { url: record, admin_view: false }
        ),
        'DT_RowData_keyword' => record.keyword,
        'DT_RowData_url' => record.url,
        'DT_RowId' => "url-#{record.id}"
      }
    end
  end

  def get_raw_records
    if current_user.blank?
      Url.includes(:group).references(:group).none
    else
      Url
        .created_by_ids(current_user.groups.pluck(:id))
        .not_in_pending_transfer_request.includes(:group).references(:group)
    end
  end

  # ==== Insert 'presenter'-like methods below if necessary

  def current_user
    @current_user ||= options[:current_user]
  end
end
