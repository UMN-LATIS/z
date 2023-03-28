class AdminGroupUrlsDatatable < AdminUrlDatatable
  def get_raw_records
    Url.where(group_id: params[:group_id]).includes(:group).references(:group)
  end
end
