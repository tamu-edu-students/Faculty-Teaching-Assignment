# frozen_string_literal: true

class WelcomeController < ApplicationController
  # Don't require login for the public welcome page
  skip_before_action :require_login, only: [:index]
  def index
    return unless logged_in?

    redirect_to user_path(@current_user), notice: "Welcome back, #{@current_user.first_name}!"
  end
end
