class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def ensure_signed_in
    redirect_to signin_path unless signed_in?
  end

  def ensure_is_admin
    current_user.admin
  end

  def urls_by_keyword(keyword)
    Url.where(
      'keyword LIKE ? AND group_id = ?',
      "%#{keyword.try(:downcase)}%",
      current_user.context_group
    )
  end

  def set_admin_view
    @admin_view = true
  end

  private

  def user_not_authorized
    flash[:error] = I18n.t :error_with_help, scope: 'pundit', default: :default
    redirect_to(request.referrer || root_path)
  end


end
