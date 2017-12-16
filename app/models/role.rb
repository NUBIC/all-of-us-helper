class Role < ActiveRecord::Base
  ROLE_ALL_OF_US_HELPER_USER = 'All of Us Helper User'
  ROLES = [ROLE_ALL_OF_US_HELPER_USER]

  has_many :role_assignments

  def self.setup
    Role::ROLES.each do |role_name|
      role = Role.where(name: role_name).first
      if role.blank?
        Role.create!(name: role_name)
      end
    end
  end
end