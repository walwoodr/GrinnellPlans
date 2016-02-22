class ApplicationController < ActionController::Base
  before_filter :require_user
  protect_from_forgery

  # Filters added to this controller apply to all controllers in the application.
  # Likewise, all the methods added will be available for all controllers.
  helper :all # include all helpers, all the time
  helper_method :current_account, :current_account_session

  def current_account
    @current_account ||= current_account_session && current_account_session.record
  end

  def current_account_session
    @current_account_session ||= AccountSession.find
  end

  def require_user
    redirect_to login_path if current_account.nil?
  end

  def require_no_user
    redirect_to root_path if current_account.present?
  end

  def require_admin
    redirect_to root_path if current_account.nil? || !current_account.is_admin?
  end

  def autofingers
    return if current_account.nil?
    @autofingers ||= ({1 => [], 2 => [], 3 => []}).merge(
      current_account.interests_in_others.updated.group_by(&:priority)
    )
  end
  helper_method :autofingers

  # Don't use this! It's for migration purposes only.
  # Use strong unsafe_params properly instead:
  # http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  def unsafe_params
    ActiveSupport::Deprecation.warn("Using `unsafe_params` isn't a great plan", caller(1))
    params.dup.tap(&:permit!)
  end
end
