class PatientPolicy < ApplicationPolicy
  def index?
    user.has_role?(Role::ROLE_ALL_OF_US_HELPER_USER)
  end

  def show?
    user.has_role?(Role::ROLE_ALL_OF_US_HELPER_USER)
  end

  def record_id?
    user.has_role?(Role::ROLE_ALL_OF_US_HELPER_USER)
  end

  def new_empi?
    user.has_role?(Role::ROLE_ALL_OF_US_HELPER_USER)
  end

  def empi_lookup?
    user.has_role?(Role::ROLE_ALL_OF_US_HELPER_USER)
  end

  def update?
    user.has_role?(Role::ROLE_ALL_OF_US_HELPER_USER)
  end

  def register?
    user.has_role?(Role::ROLE_ALL_OF_US_HELPER_USER)
  end
end