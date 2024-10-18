# frozen_string_literal: true

# SessionsController handles user authentication with OmniAuth for Google OAuth2.
class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:omniauth]

  def logout
    reset_session
    redirect_to welcome_path
  end

  def omniauth
    @user = find_or_create_user_from_auth(auth_info)

    if @user.valid?
      session[:user_id] = @user.id
      redirect_to schedules_path
    else
      redirect_to welcome_path, alert: 'Login failed'
    end
  end

  private

  def auth_info
    request.env['omniauth.auth']
  end

  def find_or_create_user_from_auth(auth)
    User.find_or_create_by(uid: auth['uid'], provider: auth['provider']) do |user|
      user.email = auth['info']['email']
      names = auth['info']['name'].split
      user.first_name = names[0]
      user.last_name = names[1..].join(' ')
    end
  end
end
