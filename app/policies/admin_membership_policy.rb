# app/policies/admin_membership_policy.rb
class AdminMembershipPolicy < Struct.new(:user, :admin_membership)

  def index?
    user.admin?
  end

  def create?
    user.admin?
  end

  def destroy?
    user.admin?
  end

end