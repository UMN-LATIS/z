module GroupHelper
  def display_name(group)
    return t('helpers.groups.default_display') if group.default?
    group.name
  end
end
