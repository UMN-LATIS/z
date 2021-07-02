class GroupPolicy < ApplicationPolicy

  def index?
    user_has_access?
  end

  def show?
    user_has_access?
  end

  def create?
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
    return true if user.admin?
    return true if record.is_a?(Group) && record.users.exists?(user.id)
    return true if record.is_a?(Array) && record.all? { |rec| rec.users.exists?(user.id) }
    false
  end

end