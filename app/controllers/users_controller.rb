# frozen_string_literal: true

class UsersController < ApplicationController
  def show
    @current_user = User.find(params[:id])
  end
end
