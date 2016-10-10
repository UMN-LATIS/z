class GroupPolicy < ApplicationPolicy

  def index?
    user_has_access?
  end

  def show?
    user_has_access?
  end

  def update?
    user_has_access?
  end

  def destroy?
    user_has_access?
  end

  private

  def user_has_access?
    user.admin? || (record.is_a?(Group) && record.user?(user)) || record.all? { |rec| rec.user?(user) }
  end

end