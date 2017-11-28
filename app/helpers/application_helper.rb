module ApplicationHelper
  def active?(css_class, url_parameters)
    current_page?(url_parameters) ? css_class : ''
  end
end