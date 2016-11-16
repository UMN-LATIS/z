class UrlPolicy < ApplicationPolicy

  def index?
    user_has_access?
  end

  def csvs?
    user_has_access?
  end

  def transfer_requests?
    user_has_access?
  end

  def admin_transfer_requests?
    user.admin?
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
    return true if user.admin?
    return true if record.is_a?(Url) && record.group.user?(user)
    return true if record.is_a?(Array) && record.all? { |rec| rec.group.user?(user)}
    false
  end

end