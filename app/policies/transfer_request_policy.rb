class TransferRequestPolicy < ApplicationPolicy

  def destroy?
    can_crud?
  end

  def update?
    can_crud?
  end

  def show?
    can_crud?
  end

  def confirm?
    can_crud?
  end

  private

  def can_crud?
    return true if user.admin?
    return true if user.in_group?(Group.find(record.from_group_id))
    false
  end


end