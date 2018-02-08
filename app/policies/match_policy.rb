class MatchPolicy < ApplicationPolicy
  def accept?
    user.has_role?(Role::ROLE_ALL_OF_US_HELPER_USER)
  end
end