class AuditPolicy < ApplicationPolicy

  def index?
    user_has_access?
  end

  def show?
    user_has_access?
  end

  private

  def user_has_access?
    return true if user.admin?
    false
  end

end