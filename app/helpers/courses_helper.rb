module CoursesHelper
    def sortable(column, title = nil)
        title ||= column.titleize
        direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
        classes = direction == 'desc' ? 'sortable-link desc' : 'sortable-link'
        link_to title, { sort: column, direction: direction}, class: classes
      end
end
