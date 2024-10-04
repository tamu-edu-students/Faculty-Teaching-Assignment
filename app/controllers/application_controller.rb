# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  # Require users to be logged in
  before_action :require_login

  private

  def current_user
    # if @current _user is undefined or falsy, evaluate the RHS
    # Look up user by id if user id is in the session hash
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
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
