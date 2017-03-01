class AdminUrlDatatable < AjaxDatatablesRails::Base
  def_delegators :@view, :link_to, :full_url, :display_url

    def sortable_columns
      # Declare strings in this format: ModelName.column_name
      @sortable_columns ||= [
        'Group.name',
        'Url.url',
        'Url.keyword',
        'Url.total_clicks',
        'Url.created_at'
      ]
    end

    def searchable_columns
      # Declare strings in this format: ModelName.column_name
      @searchable_columns ||= [
        nil,
        'Group.name',
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
          '1' => record.group.name,
          '2' => link_to(display_url(record), record.url, target: '_blank'),
          '3' => link_to(full_url(record), full_url(record), target: '_blank'),
          '4' => record.total_clicks,
          '5' => record.created_at.to_s(:created_on_formatted),
          '6' =>
            ApplicationController.renderer.render(
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
