class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper Starburst::AnnouncementsHelper

  before_action :set_paper_trail_whodunnit
  before_action :ping_lookup_service

  def info_for_paper_trail
    { :whodunnit_name => current_user.user_full_name, :whodunnit_email => current_user.email } if signed_in?
  end

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

  def ping_lookup_service
    unless UserLookupService.new.ping
      flash.now[:error] = I18n.t 'controllers.application.lookup_service_down'
      render file: 'public/lookup_service_down.html', layout: false
    end
  end

  def redirect_to_urls_if_logged_in
    redirect_to urls_path unless !signed_in?
  end
end
