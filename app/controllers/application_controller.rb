class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  helper Starburst::AnnouncementsHelper

  before_action :set_paper_trail_whodunnit
  before_action :expire_cache_headers

  before_action :set_notification

  def set_notification
    request.env['exception_notifier.exception_data'] = { 'server' => request.env['SERVER_NAME'] }
    # can be any key-value pairs
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

  def render_not_found
    render template: 'errors/not_found', layout: 'layouts/application', status: 404, formats: [ :html ]
  end

  private

  def user_not_authorized
    flash[:error] = I18n.t :error_with_help, scope: 'pundit', default: :default
    redirect_to(request.referer || root_path)
  end

  def redirect_to_urls_if_logged_in
    redirect_to urls_path if signed_in?
  end

  def expire_cache_headers
    response.headers['Cache-Control'] = 'no-cache, no-store'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end

end
