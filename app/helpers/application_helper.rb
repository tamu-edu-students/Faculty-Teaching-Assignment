# frozen_string_literal: true

# ApplicationHelper is used to store helper methods that can be used across views.
module ApplicationHelper
  TAB_LIST = [
    {
      id: 'rooms',
      title: 'Rooms',
      link: '/rooms/index'
    },
    {
      id: 'courses',
      title: 'Courses',
      link: '#'
    },
    {
      id: 'instructors',
      title: 'Instructors',
      link: '#'
    },
    {
      id: 'time-slots',
      title: 'Time Slots',
      link: '#'
    }
  ].freeze

  def render_navbar(active_tab, schedule_name)
    render partial: '/shared/insched_nav', locals: { tabs: TAB_LIST, active_tab: active_tab, schedule_name: schedule_name }
  end
end
