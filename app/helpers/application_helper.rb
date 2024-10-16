# frozen_string_literal: true

# ApplicationHelper is used to store helper methods that can be used across views.
module ApplicationHelper
    TAB_LIST = [
        {
            id: "rooms",
            title: "Rooms",
            link: "/rooms/index"
        },
        {
            id: "courses",
            title: "Courses",
            link: "#"
        },
        {
            id: "instructors",
            title: "Instructors",
            link: "#"
        },
        {
            id: "time-slots",
            title: "Time Slots",
            link: "#"
        }
    ]

    def render_navbar (active_tab)
        render partial: "/shared/insched_nav", locals: {tabs: TAB_LIST, active_tab: active_tab}
    end
end
