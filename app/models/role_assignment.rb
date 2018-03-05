class RoleAssignment < ActiveRecord::Base
  has_paper_trail
  belongs_to :role
  belongs_to :user
end