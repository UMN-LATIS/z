module GroupHelper
  def display_name(group)
    return 'No Collection' if group.default?
    group.name
  end
end
