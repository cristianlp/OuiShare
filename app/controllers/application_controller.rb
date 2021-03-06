class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :set_locale
  before_filter :set_language

  def after_sign_in_path_for(resource)
    if current_user.admin?
      admin_home_path
    else
      root_path
    end
  end

  unless Rails.application.config.consider_all_requests_local
    rescue_from ActionController::RoutingError do |exception|

      # Put loggers here, if desired.

      render template: 'errors/not_found', status: 404
    end
  end

  protected
  def render_404
    raise ActionController::RoutingError.new('Not Found')
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:account_update) << [:name, :email, :email_address, :password, :password_confirmation, :bio, :facebook_url, :twitter_url, :google_plus_url, :github_url, :linkedin_url, :profile_type, :tag_list, :image, :title]
  end

  def set_locale
    if params[:locale]
      I18n.locale = params[:locale]
      current_user.update_attribute :locale, params[:locale] if current_user && params[:locale] != current_user.locale
    elsif request.method == "GET"
      new_locale = (current_user.locale if current_user) || I18n.default_locale
      redirect_to params.merge(locale: new_locale, only_path: true)
    end
  end

  def set_language
    @current_language = Language.where(slug: I18n.locale.to_s).first
  end

  def render_404
    respond_to do |format|
      format.html { render template: 'errors/not_found', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end
end

