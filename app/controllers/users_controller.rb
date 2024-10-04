# frozen_string_literal: true

# UsersController handles displaying user-related data.
# The show action retrieves and displays the current user based on the ID provided in the parameters.
class UsersController < ApplicationController
  def show
    @current_user = User.find(params[:id])
  end
end
