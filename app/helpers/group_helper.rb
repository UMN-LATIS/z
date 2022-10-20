module GroupHelper
  def display_name(group)
    return t('views.urls.index.table.collection_filter.none') if group.default?

    group.name
  end

  def group_names_and_ids_for_select(groups)
    groups.collect do |group|
      [display_name(group), group['id']]
    end.sort_by { |group| [group.first == "No Collection" ? 0 : 1, group.first.downcase] }
  end
end
