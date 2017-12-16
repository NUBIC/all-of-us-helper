class SettingPolicy < ApplicationPolicy
  def edit?
    user.has_role?(Role::ROLE_ALL_OF_US_HELPER_USER)
  end

  def update?
    user.has_role?(Role::ROLE_ALL_OF_US_HELPER_USER)
  end
end