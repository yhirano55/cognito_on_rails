class SessionsController < ApplicationController
  skip_before_action :authenticate!, only: [:new, :create]

  def new
  end

  def create
    user = UserIdentityConnector.new(user: current_user, omniauth: omniauth).connect_or_create
    create_session_with(user)
    redirect_to root_path, notice: "logged in"
  end

  def destroy
    destroy_session
    redirect_to login_path, notice: "logged out"
  end

  private

  def omniauth
    request.env['omniauth.auth']
  end

  def create_session_with(user)
    reset_session
    session[:user_id] = user.id
  end

  def destroy_session
    session.delete(:user_id)
  end
end
