# frozen_string_literal: true

# ApplicationController serves as the base controller for all other controllers in the application.
# It enforces user authentication for all actions unless overridden, and supports browser version
# restrictions for modern features like webp images, web push, badges, etc.
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  # Require users to be logged in
  before_action :require_login

  private

  def current_user
    # if @current _user is undefined or falsy, evaluate the RHS
    # Look up user by id if user id is in the session hash
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user
  end

  def require_login
    # redirect to the welcome page unless user is logged in
    return if logged_in?

    redirect_to welcome_path, alert: 'You must be logged in to access this section.'
  end

end
