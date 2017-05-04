module GroupHelper
  def display_name(group)
    return t('views.urls.index.table.collection_filter.none') if group.default?
    group.name
  end
end
