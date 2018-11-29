class ApplicationController < ActionController::Base
  before_action :authenticate!
  helper_method :current_user, :logged_in?

  private

  def authenticate!
    redirect_to login_path unless logged_in?
  end

  def logged_in?
    !current_user.nil?
  end

  def current_user
    return @current_user if defined?(@current_user)
    return unless session[:user_id]

    @current_user = User.find(session[:user_id])
  rescue ActiveRecord::RecordNotFound
    reset_session
  end
end
