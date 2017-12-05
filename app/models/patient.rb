class Patient < ApplicationRecord
  has_many :invitation_code_assignments

  scope :search_across_fields, ->(search_token, options={}) do
    if search_token
      search_token.downcase!
    end
    options = { sort_column: 'last_name', sort_direction: 'asc' }.merge(options)

    if search_token
      p = where(["lower(record_id) like ? OR lower(last_name) like ? OR lower(first_name) like ? OR lower(email) like ?", "%#{search_token}%", "%#{search_token}%", "%#{search_token}%", "%#{search_token}%"])
    end

    sort = options[:sort_column] + ' ' + options[:sort_direction] + ', patients.id ASC'
    p = p.nil? ? order(sort) : p.order(sort)

    p
  end

  def invitation_code
     if invitation_code_assignments.is_active.any?
       invitation_code_assignments.is_active.first.invitation_code.code
     end
  end

  def full_name
    name = [first_name, last_name].compact.join(' ')
  end
end