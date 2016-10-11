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
    user.admin? || (record.is_a?(Group) && record.users.exists?(user.id)) || (record.is_a?(Array) && record.all? { |rec| rec.users.exists?(user.id) })
  end

end