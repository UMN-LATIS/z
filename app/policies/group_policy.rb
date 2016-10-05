class GroupPolicy < ApplicationPolicy
  def update?
    user.admin? or not record.published?
  end
end