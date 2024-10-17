module RoomsHelper
    def display_usage_type (value, is_active)
        classes = "bg-secondary"
        message = "NA"
        extra_classes = ""
        if is_active
            extra_classes = " fw-bold text-white"
        end
        if value
            classes = "bg-success"
            message = "Yes"
        elsif is_active
            classes = "bg-danger"
            message = "No"
        else
            classes = "bg-secondary"
        end
        classes += extra_classes
        render partial: "/rooms/usage_type", locals: {classes: classes, message: message}
    end

    def sortable(column, title = nil)
        title ||= column.titleize
        direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
        classes = (direction == "asc") ? "sortable-link" : "sortable-link desc";
        link_to title, { sort: column, direction: direction, active: params[:active_rooms] }, class: classes
    end
end
