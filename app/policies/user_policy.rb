class UserPolicy < ApplicationPolicy
  def show?
    user.has_role?(Role::ROLE_ALL_OF_US_HELPER_USER) && user == record
  end
end