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
end
