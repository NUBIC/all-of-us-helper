module ApplicationHelper
  def active?(css_class, url_parameters)
    current_page?(url_parameters) ? css_class : ''
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, params.permit(:sort, :direction, :search, :last_name, :first_name, :record_id, :email).merge({ sort: column, direction: direction }), { class: css_class }
  end
end