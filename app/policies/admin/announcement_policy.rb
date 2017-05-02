class Admin::AnnouncementPolicy < ApplicationPolicy

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
    false
  end

end