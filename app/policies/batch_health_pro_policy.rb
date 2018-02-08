class BatchHealthProPolicy < ApplicationPolicy
  def index?
    user.has_role?(Role::ROLE_ALL_OF_US_HELPER_USER)
  end

  def new?
    user.has_role?(Role::ROLE_ALL_OF_US_HELPER_USER)
  end

  def create?
    user.has_role?(Role::ROLE_ALL_OF_US_HELPER_USER)
  end

  def show?
    user.has_role?(Role::ROLE_ALL_OF_US_HELPER_USER)
  end
end
