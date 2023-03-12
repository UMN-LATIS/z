class AdminGroupDatatable < ApplicationDatatable
  def_delegators :@view, :render

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      id: {source: "Group.id", cond: :eq},
      name: {source: "Group.name", cond: :like},
      description: {source: "Group.description"},
      users: {source: "Group.users", searchable: false, orderable: false},
      urls: {source: "Group.urls", searchable: false, orderable: false},
      actions: {searchable: false, orderable: false}
    }
  end

  def data
    records.map do |record|
      {
        id: record.id,
        name: record.name,
        description: record.description,
        users: record.users.size,
        urls: record.urls.size,
        actions: nil, # rendered client side
        DT_RowId: "group-#{record.id}"
      }
    end
  end

  def get_raw_records
    Group.includes(:users, :urls).not_default
  end
end
